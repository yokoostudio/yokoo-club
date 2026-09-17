// Recibe la reseña desde la página pública (resena.html) y, a cambio:
//   1) la guarda como "pending" para que Juan la modere,
//   2) crea un cupón real y único de 10% en Tiendanube,
//   3) suma una estrella en la tarjeta de fidelidad (si esa persona está
//      registrada en el club),
//   4) manda el mail de agradecimiento con el código.
//
// No usa verify_jwt: la persona NO necesita estar logueada. La autoriza el
// token único de su compra, que sólo llegó a su casilla.

import { sendReviewThanksEmail } from "../_shared/notify.ts";

const REVIEW_DISCOUNT_PERCENT = "10";
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let body: { token?: string; rating?: number; comment?: string; name?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  const token = String(body.token || "").trim();
  const rating = parseInt(String(body.rating || ""), 10);
  const comment = String(body.comment || "").trim().slice(0, 1000);
  const name = String(body.name || "").trim().slice(0, 80);

  if (!token) return json({ error: "Falta el link de tu compra" }, 400);
  if (!(rating >= 1 && rating <= 5)) return json({ error: "Elegí de 1 a 5 estrellas" }, 400);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  // 1) Validar el token.
  const rowRes = await fetch(
    `${supabaseUrl}/rest/v1/reviews?token=eq.${encodeURIComponent(token)}&select=id,order_id,customer_email,customer_name,submitted_at,coupon_code`,
    { headers: svcHeaders }
  );
  const review = (await rowRes.json())?.[0];
  if (!review) return json({ error: "Este link no es válido" }, 404);
  if (review.submitted_at) {
    return json({ ok: true, alreadySubmitted: true, code: review.coupon_code || null }, 200);
  }

  // 2) Guardar la reseña (queda pendiente de moderación).
  const code = "OPINION10-" + randomSuffix();
  const patchRes = await fetch(`${supabaseUrl}/rest/v1/reviews?id=eq.${review.id}`, {
    method: "PATCH",
    headers: svcHeaders,
    body: JSON.stringify({
      rating,
      comment,
      customer_name: name || review.customer_name,
      submitted_at: new Date().toISOString(),
      status: "pending",
      coupon_code: code,
    }),
  });
  if (!patchRes.ok) {
    console.error("No se pudo guardar la reseña:", patchRes.status, await patchRes.text());
    return json({ error: "No se pudo guardar tu reseña" }, 500);
  }

  // 3) Cupón real de 10% en Tiendanube (mismo mecanismo que tn-welcome-coupon).
  let couponOk = false;
  const connRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?select=store_id,access_token&limit=1`,
    { headers: svcHeaders }
  );
  const conn = (await connRes.json())?.[0];
  if (conn) {
    const couponRes = await fetch(`https://api.tiendanube.com/v1/${conn.store_id}/coupons`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authentication: `bearer ${conn.access_token}`,
        "User-Agent": "Yokoo Club (jcdibastiano@gmail.com)",
      },
      body: JSON.stringify({
        code,
        type: "percentage",
        value: REVIEW_DISCOUNT_PERCENT,
        valid: true,
        max_uses: 1,
      }),
    });
    couponOk = couponRes.ok;
    if (!couponOk) console.error("Error creando cupón de reseña:", couponRes.status, await couponRes.text());
  }

  // 4) Estrella extra en la tarjeta, sólo si esa persona está registrada.
  const starAwarded = await tryAddStar(supabaseUrl, svcHeaders, review.customer_email, review.order_id);

  // 5) Agradecimiento con el código.
  await sendReviewThanksEmail({
    toEmail: review.customer_email,
    displayName: name || review.customer_name,
    code,
    percent: REVIEW_DISCOUNT_PERCENT,
    starAwarded,
    appUrl: Deno.env.get("APP_URL") || "http://localhost:8888",
  });

  console.log("Reseña recibida:", review.customer_email, rating, "estrellas | cupón:", couponOk, "| estrella:", starAwarded);
  return json({ ok: true, code, couponOk, starAwarded }, 200);
});

// Suma un sello con source="review". El UNIQUE(source, order_id) de
// stamp_events evita que la misma compra sume dos veces.
async function tryAddStar(
  supabaseUrl: string,
  svcHeaders: Record<string, string>,
  email: string,
  orderId: string
): Promise<boolean> {
  try {
    const custRes = await fetch(
      `${supabaseUrl}/rest/v1/customers?email=eq.${encodeURIComponent(email)}&select=id,current_stamps`,
      { headers: svcHeaders }
    );
    const customer = (await custRes.json())?.[0];
    if (!customer) return false;

    const insertRes = await fetch(`${supabaseUrl}/rest/v1/stamp_events`, {
      method: "POST",
      headers: { ...svcHeaders, Prefer: "return=minimal" },
      body: JSON.stringify({ customer_id: customer.id, source: "review", order_id: orderId }),
    });
    if (!insertRes.ok) return false;

    const goalRes = await fetch(`${supabaseUrl}/rest/v1/settings?key=eq.stamps_goal&select=value`, { headers: svcHeaders });
    const goal = parseInt((await goalRes.json())?.[0]?.value ?? "5", 10);
    const newStamps = Math.min(customer.current_stamps + 1, goal);

    await fetch(`${supabaseUrl}/rest/v1/customers?id=eq.${customer.id}`, {
      method: "PATCH",
      headers: svcHeaders,
      body: JSON.stringify({ current_stamps: newStamps }),
    });
    return true;
  } catch (e) {
    console.error("Excepción sumando la estrella de reseña:", e);
    return false;
  }
}

function randomSuffix(): string {
  return Math.random().toString(36).slice(2, 8).toUpperCase();
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}
