// Dispara las campañas que ya llegaron a su hora. La llama el cron de la base
// una vez por minuto (ver supabase/sql/parte-15-cron-campanias.sql): si no hay
// nada agendado devuelve enseguida sin hacer nada.
//
// No manda los mails por su cuenta: arma el body y llama a campaign-send, que
// es la que ya está probada. Un salto HTTP de más, a cambio de no duplicar la
// lógica de envío en dos lugares.
//
// verify_jwt = false; se protege con CAMPAIGN_SECRET (o CRON_SECRET) en el
// header x-yokoo-cron-secret, igual que campaign-send.

// Cuántas campañas atrasadas procesa por corrida. Es un tope de seguridad: si
// algo quedó mal agendado, no se disparan veinte campañas de golpe.
const MAX_POR_CORRIDA = 3;

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const campaignSecret = Deno.env.get("CAMPAIGN_SECRET");
  const cronSecret = Deno.env.get("CRON_SECRET");
  const given = req.headers.get("x-yokoo-cron-secret");
  const ok = (campaignSecret && given === campaignSecret) || (cronSecret && given === cronSecret);
  if (!ok) return json({ error: "No autorizado" }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  const ahora = new Date().toISOString();
  const res = await fetch(
    `${supabaseUrl}/rest/v1/campaigns?select=id,slug,subject,content,test_email` +
      `&sent_at=is.null&scheduled_at=lte.${encodeURIComponent(ahora)}` +
      `&order=scheduled_at&limit=${MAX_POR_CORRIDA}`,
    { headers: svcHeaders },
  );
  if (!res.ok) {
    console.error("Error leyendo campaigns:", res.status, await res.text());
    return json({ error: "No se pudo leer las campañas" }, 500);
  }

  const pendientes = (await res.json()) as {
    id: string;
    slug: string;
    subject: string;
    content: Record<string, unknown>;
    test_email: string | null;
  }[];

  if (pendientes.length === 0) return json({ ok: true, disparadas: 0 }, 200);

  const disparadas: { slug: string; resultado: unknown }[] = [];

  for (const c of pendientes) {
    // Se reserva la campaña ANTES de mandarla: el update sólo pega si sent_at
    // sigue en null, así que si dos corridas del cron se pisan, una sola la
    // agarra. Si el envío después falla, campaign_sends evita que un reintento
    // manual le mande de nuevo a quien ya la recibió.
    const claim = await fetch(
      `${supabaseUrl}/rest/v1/campaigns?id=eq.${c.id}&sent_at=is.null`,
      {
        method: "PATCH",
        headers: { ...svcHeaders, Prefer: "return=representation" },
        body: JSON.stringify({ sent_at: new Date().toISOString() }),
      },
    );
    const reservada = claim.ok ? ((await claim.json()) as unknown[]).length > 0 : false;
    if (!reservada) continue;

    const body: Record<string, unknown> = {
      ...c.content,
      slug: c.slug,
      subject: c.subject,
    };
    if (c.test_email) body.testEmails = [c.test_email];

    let resultado: unknown;
    try {
      const envio = await fetch(`${supabaseUrl}/functions/v1/campaign-send`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-yokoo-cron-secret": given!,
        },
        body: JSON.stringify(body),
      });
      resultado = await envio.json().catch(() => ({ status: envio.status }));
      if (!envio.ok) console.error(`Campaña ${c.slug} falló:`, envio.status, resultado);
    } catch (e) {
      console.error(`Excepción disparando ${c.slug}:`, e);
      resultado = { error: String(e) };
    }

    await fetch(`${supabaseUrl}/rest/v1/campaigns?id=eq.${c.id}`, {
      method: "PATCH",
      headers: { ...svcHeaders, Prefer: "return=minimal" },
      body: JSON.stringify({ result: resultado }),
    });

    disparadas.push({ slug: c.slug, resultado });
  }

  return json({ ok: true, disparadas: disparadas.length, detalle: disparadas }, 200);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
