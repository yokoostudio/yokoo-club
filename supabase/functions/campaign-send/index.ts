// Manda una campaña a toda la lista del Club (lanzamiento de colección,
// CyberMonday, etc.). A diferencia del resto de las funciones de este
// proyecto, el CONTENIDO del mail no está en el código: llega en el body del
// request, así la misma función sirve para todas las campañas sin tocar nada.
//
// No usa verify_jwt: se protege con el mismo secreto propio que review-invites
// (header x-yokoo-cron-secret).
//
// Tres modos:
//   { dryRun: true }              -> cuenta a cuántos les tocaría, no manda nada
//   { testEmails: ["a@b.com"] }   -> manda sólo a esas casillas, no registra nada
//   (sin ninguno de los dos)      -> corrida real a toda la lista
//
// La guarda anti-duplicado es la tabla campaign_sends (UNIQUE campaña+mail):
// volver a correr la misma campaña sólo le manda a quien todavía no la recibió.

import {
  sendCampaignBatch,
  sendCampaignReport,
  type CampaignContent,
  type CampaignRecipient,
} from "../_shared/notify.ts";

const OWNER_EMAIL = "jcdibastiano@gmail.com";

// Tope de seguridad: si la lista crece más que esto, la corrida se corta y
// avisa, en vez de mandar miles de mails por un error de filtro.
const MAX_PER_RUN = 1000;

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  // Secreto propio de campañas, separado del CRON_SECRET que usa el cron de
  // reseñas: así se puede rotar uno sin tocar el otro. Se sigue aceptando
  // CRON_SECRET por compatibilidad.
  const campaignSecret = Deno.env.get("CAMPAIGN_SECRET");
  const cronSecret = Deno.env.get("CRON_SECRET");
  const given = req.headers.get("x-yokoo-cron-secret");
  const ok =
    (campaignSecret && given === campaignSecret) || (cronSecret && given === cronSecret);
  if (!ok) return json({ error: "No autorizado" }, 401);
  const expected = campaignSecret || cronSecret!;

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Falta el body" }, 400);
  }

  const slug = String(body?.slug || "").trim();
  const subject = String(body?.subject || "").trim();
  const headline = String(body?.headline || "").trim();
  const paragraphs = Array.isArray(body?.paragraphs)
    ? (body.paragraphs as unknown[]).map((p) => String(p)).filter((p) => p.trim())
    : [];

  if (!slug || !subject || !headline || paragraphs.length === 0) {
    return json(
      { error: "Faltan campos: slug, subject, headline y al menos un párrafo en paragraphs" },
      400,
    );
  }

  const content: CampaignContent = {
    headline,
    paragraphs,
    images: Array.isArray(body?.images)
      ? (body.images as unknown[]).map((u) => String(u).trim()).filter(Boolean)
      : undefined,
    imageUrl: body?.imageUrl ? String(body.imageUrl) : undefined,
    imageAlt: body?.imageAlt ? String(body.imageAlt) : undefined,
    ctaText: body?.ctaText ? String(body.ctaText) : undefined,
    ctaUrl: body?.ctaUrl ? String(body.ctaUrl) : undefined,
    footnote: body?.footnote ? String(body.footnote) : undefined,
    codigo: body?.codigo ? String(body.codigo) : undefined,
    codigoLabel: body?.codigoLabel ? String(body.codigoLabel) : undefined,
  };

  const audiencia = ["compraron","no_compraron"].includes(String(body?.audiencia || ""))
    ? String(body.audiencia)
    : "todos";
  const audienciaDesde = body?.audienciaDesde ? String(body.audienciaDesde) : "";
  const audienciaHasta = body?.audienciaHasta ? String(body.audienciaHasta) : "";

  const dryRun = body?.dryRun === true;
  const testEmails = Array.isArray(body?.testEmails)
    ? (body.testEmails as unknown[]).map((e) => String(e).trim().toLowerCase()).filter(Boolean)
    : [];

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const resendKey = Deno.env.get("RESEND_API_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  // Tiene que ser EXACTAMENTE el mismo fallback que usa campaign-unsubscribe
  // (UNSUB_SECRET, si no CRON_SECRET). Si acá se usara CAMPAIGN_SECRET, las
  // firmas no coincidirían y todos los links de baja quedarían inválidos.
  const unsubSecret = Deno.env.get("UNSUB_SECRET") || Deno.env.get("CRON_SECRET")!;
  const unsubBase = `${supabaseUrl}/functions/v1/campaign-unsubscribe`;

  // --- Modo prueba: sólo a las casillas indicadas, sin registrar nada -------
  if (testEmails.length > 0) {
    const recipients: CampaignRecipient[] = [];
    for (const email of testEmails) {
      recipients.push({
        email,
        name: "prueba",
        unsubUrl: `${unsubBase}?e=${encodeURIComponent(email)}&t=${await sign(email, unsubSecret)}`,
      });
    }
    const result = await sendCampaignBatch(resendKey, subject, content, recipients);
    return json(
      { ok: true, mode: "test", sent: result.sent.length, failed: result.failed.length },
      200,
    );
  }

  // --- Destinatarios reales -------------------------------------------------
  const res = await fetch(
    `${supabaseUrl}/rest/v1/customers?select=id,email,display_name&unsubscribed=is.false&email=not.is.null&order=email`,
    { headers: svcHeaders },
  );
  if (!res.ok) {
    console.error("Error leyendo customers:", res.status, await res.text());
    return json({ error: "No se pudo leer la lista de clientes" }, 500);
  }
  let customers = (await res.json()) as { id: string; email: string; display_name: string | null }[];

  // --- Segmentación por compras --------------------------------------------
  // "compraron" / "no_compraron" miran las compras web registradas entre
  // audiencia_desde y audiencia_hasta. Se usa stamp_events porque cada compra
  // web deja una estrella con su fecha: no hace falta volver a consultar
  // Tiendanube ni guardar ningún dato nuevo.
  if (audiencia === "compraron" || audiencia === "no_compraron") {
    let filtro = `source=in.(web_order,cyber_bonus)`;
    if (audienciaDesde) filtro += `&created_at=gte.${encodeURIComponent(audienciaDesde)}`;
    if (audienciaHasta) filtro += `&created_at=lte.${encodeURIComponent(audienciaHasta)}`;

    const cr = await fetch(
      `${supabaseUrl}/rest/v1/stamp_events?select=customer_id&${filtro}`,
      { headers: svcHeaders },
    );
    if (!cr.ok) {
      console.error("Error leyendo stamp_events:", cr.status, await cr.text());
      return json({ error: "No se pudo calcular el segmento" }, 500);
    }
    const compradores = new Set(
      ((await cr.json()) as { customer_id: string }[]).map((r) => r.customer_id),
    );

    customers = customers.filter((c) =>
      audiencia === "compraron" ? compradores.has(c.id) : !compradores.has(c.id)
    );

    // Un segmento vacío casi siempre es un error de fechas, no un caso real.
    // Mejor frenar y avisar que mandar una campaña a nadie en silencio.
    if (customers.length === 0) {
      return json(
        { error: `El segmento "${audiencia}" no tiene a nadie. Revisá las fechas antes de mandar.` },
        400,
      );
    }
  }

  // Quiénes ya recibieron ESTA campaña (corrida anterior cortada a la mitad).
  const sentRes = await fetch(
    `${supabaseUrl}/rest/v1/campaign_sends?select=email&campaign_slug=eq.${encodeURIComponent(slug)}`,
    { headers: svcHeaders },
  );
  const already = new Set<string>(
    sentRes.ok ? ((await sentRes.json()) as { email: string }[]).map((r) => r.email.toLowerCase()) : [],
  );

  const pending = customers.filter((c) => c.email && !already.has(c.email.toLowerCase()));

  if (pending.length === 0) {
    return json({ ok: true, sent: 0, skipped: already.size, mensaje: "Ya la recibieron todos" }, 200);
  }

  if (pending.length > MAX_PER_RUN) {
    return json(
      { error: `La lista tiene ${pending.length} destinatarios, más que el tope de ${MAX_PER_RUN}. Revisá el filtro antes de mandar.` },
      400,
    );
  }

  if (dryRun) {
    return json(
      {
        ok: true,
        dryRun: true,
        destinatarios: pending.length,
        yaRecibieron: already.size,
        dadosDeBaja: customers.length === 0 ? "?" : undefined,
        audiencia,
        muestra: pending.slice(0, 5).map((c) => maskEmail(c.email)),
        asunto: subject,
      },
      200,
    );
  }

  // --- Envío real -----------------------------------------------------------
  const recipients: CampaignRecipient[] = [];
  for (const c of pending) {
    const email = c.email.toLowerCase();
    recipients.push({
      email,
      name: firstName(c.display_name),
      unsubUrl: `${unsubBase}?e=${encodeURIComponent(email)}&t=${await sign(email, unsubSecret)}`,
    });
  }

  const result = await sendCampaignBatch(resendKey, subject, content, recipients);

  // Registrar SÓLO los que salieron, para que un reintento mande nada más que
  // los que fallaron.
  if (result.sent.length > 0) {
    const rows = result.sent.map((email) => ({ campaign_slug: slug, email }));
    const ins = await fetch(`${supabaseUrl}/rest/v1/campaign_sends`, {
      method: "POST",
      headers: { ...svcHeaders, Prefer: "resolution=ignore-duplicates,return=minimal" },
      body: JSON.stringify(rows),
    });
    if (!ins.ok) {
      console.error("Error registrando campaign_sends:", ins.status, await ins.text());
    }
  }

  await sendCampaignReport({
    apiKey: resendKey,
    ownerEmail: OWNER_EMAIL,
    slug,
    subject,
    sent: result.sent.length,
    failed: result.failed.length,
    skipped: already.size,
  });

  return json(
    { ok: true, sent: result.sent.length, failed: result.failed.length, skipped: already.size },
    200,
  );
});

// Firma del link de baja: sin esto cualquiera podría dar de baja a otro
// cambiando el mail en la URL.
async function sign(email: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(email.toLowerCase()));
  return Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("")
    .slice(0, 32);
}

function firstName(displayName: string | null): string {
  if (!displayName) return "";
  const first = displayName.trim().split(/\s+/)[0];
  return first.length > 1 ? first : "";
}

function maskEmail(email: string): string {
  const [user, domain] = email.split("@");
  if (!domain) return "***";
  return user.slice(0, 2) + "***@" + domain;
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
