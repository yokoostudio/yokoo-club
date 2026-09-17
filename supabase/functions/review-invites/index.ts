// Corre una vez por día (pg_cron, ver supabase/sql/parte-12-cron-reviews.sql):
// busca las compras pagadas de hace ~14 días y le manda a cada cliente la
// invitación a dejar su reseña, con un link único por compra.
//
// No usa verify_jwt (la llama el cron de la base, no un usuario logueado):
// se protege con un secreto propio en el header x-yokoo-cron-secret.

import { sendReviewInviteEmail } from "../_shared/notify.ts";

// Se invita a las compras de entre 14 y 21 días atrás. La ventana es ancha a
// propósito: si un día el cron falla, esas compras se recuperan al día
// siguiente. El UNIQUE(order_id) de la tabla evita invitar dos veces.
const DAYS_MIN = 14;
const DAYS_MAX = 21;
// Tope por corrida para no comerse la cuota diaria de Resend (100/día en el
// plan gratis, compartida con los mails de login y de estrellas).
const MAX_INVITES_PER_RUN = 40;

const PAGE_SIZE = 200;
const MAX_PAGES = 15;

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const expected = Deno.env.get("CRON_SECRET");
  if (!expected || req.headers.get("x-yokoo-cron-secret") !== expected) {
    return json({ error: "No autorizado" }, 401);
  }

  // Modo de prueba: cuenta a cuántas compras les correspondería la
  // invitación, sin escribir nada ni mandar un solo mail. Sirve para
  // verificar el escaneo de pedidos sin molestar a clientes reales.
  let dryRun = false;
  // testEmail: manda UNA invitación real a esa casilla y nada más -- sirve
  // para recorrer el circuito completo (invitación -> reseña -> cupón) sin
  // tocar clientes reales ni esperar al envío automático.
  let testEmail = "";
  try {
    const body = await req.json();
    dryRun = body?.dryRun === true;
    testEmail = String(body?.testEmail || "").trim().toLowerCase();
  } catch {
    // sin body (el cron no manda ninguno): corrida normal
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  const appUrl = (Deno.env.get("APP_URL") || "http://localhost:8888").replace(/\/+$/, "");

  if (testEmail) {
    const token = crypto.randomUUID().replace(/-/g, "");
    const insertRes = await fetch(`${supabaseUrl}/rest/v1/reviews`, {
      method: "POST",
      headers: { ...svcHeaders, Prefer: "return=minimal" },
      body: JSON.stringify({
        order_id: "PRUEBA-" + Date.now(),
        customer_email: testEmail,
        customer_name: null,
        token,
        invited_at: new Date().toISOString(),
      }),
    });
    if (!insertRes.ok) {
      return json({ ok: false, error: "No se pudo crear la fila de prueba" }, 500);
    }
    const sent = await sendReviewInviteEmail({
      toEmail: testEmail,
      displayName: null,
      reviewUrl: `${appUrl}/resena.html?t=${token}`,
    });
    return json({ ok: true, testEmail: maskEmail(testEmail), sent }, 200);
  }

  const connRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?select=store_id,access_token&limit=1`,
    { headers: svcHeaders }
  );
  const conn = (await connRes.json())?.[0];
  if (!conn) return json({ ok: true, invited: 0, note: "sin conexión con Tiendanube" }, 200);

  const now = Date.now();
  const minMs = now - DAYS_MAX * 24 * 60 * 60 * 1000;
  const maxMs = now - DAYS_MIN * 24 * 60 * 60 * 1000;

  const tnHeaders = {
    Authentication: `bearer ${conn.access_token}`,
    "User-Agent": "Yokoo Club (jcdibastiano@gmail.com)",
  };

  // Mismo criterio que tn-backfill-stamps: el orden de /orders no es
  // confiable y created_at_min no filtra bien, así que recorremos las
  // páginas y filtramos la fecha acá.
  type Candidate = { orderId: string; email: string; name: string | null };
  const candidates: Candidate[] = [];

  for (let page = 1; page <= MAX_PAGES; page++) {
    const url = `https://api.tiendanube.com/v1/${conn.store_id}/orders?payment_status=paid&per_page=${PAGE_SIZE}&page=${page}`;
    const res = await fetch(url, { headers: tnHeaders });
    if (!res.ok) {
      console.error("Error listando pedidos", res.status, await res.text());
      break;
    }
    const orders = await res.json();
    if (!Array.isArray(orders) || orders.length === 0) break;

    for (const order of orders) {
      const createdMs = Date.parse(order?.created_at ?? "");
      if (isNaN(createdMs) || createdMs < minMs || createdMs >= maxMs) continue;
      const email = String(order?.customer?.email || order?.contact_email || "").toLowerCase().trim();
      if (!email) continue;
      candidates.push({
        orderId: String(order.id),
        email,
        name: order?.customer?.name || order?.contact_name || null,
      });
    }

    if (orders.length < PAGE_SIZE) break;
  }

  if (candidates.length === 0) return json({ ok: true, invited: 0, dryRun }, 200);

  if (dryRun) {
    return json({
      ok: true,
      dryRun: true,
      invited: 0,
      candidates: candidates.length,
      ejemplo: candidates.slice(0, 3).map((c) => ({ orderId: c.orderId, email: maskEmail(c.email) })),
    }, 200);
  }

  let invited = 0;
  for (const cand of candidates) {
    if (invited >= MAX_INVITES_PER_RUN) break;

    const token = crypto.randomUUID().replace(/-/g, "");

    // El UNIQUE(order_id) hace de guardia: si esta compra ya fue invitada,
    // el insert falla y seguimos de largo sin mandar nada.
    const insertRes = await fetch(`${supabaseUrl}/rest/v1/reviews`, {
      method: "POST",
      headers: { ...svcHeaders, Prefer: "return=minimal" },
      body: JSON.stringify({
        order_id: cand.orderId,
        customer_email: cand.email,
        customer_name: cand.name,
        token,
        invited_at: new Date().toISOString(),
      }),
    });
    if (!insertRes.ok) continue;

    const ok = await sendReviewInviteEmail({
      toEmail: cand.email,
      displayName: cand.name,
      reviewUrl: `${appUrl}/resena.html?t=${token}`,
    });
    if (ok) invited++;
  }

  console.log("Invitaciones a reseñar enviadas:", invited, "de", candidates.length, "candidatas");
  return json({ ok: true, invited, candidates: candidates.length }, 200);
});

// Para el modo de prueba: no queremos volcar mails completos de clientes
// reales en una respuesta de diagnóstico.
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
