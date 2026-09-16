// Se llama una vez, justo después del backfill, la primera vez que un
// cliente entra a la tarjeta. Si nunca compró (ni siquiera algo que el
// backfill haya encontrado retroactivamente), le manda un mail de
// bienvenida con un cupón real de descuento para su primera compra.
//
// IMPORTANTE: debe invocarse DESPUÉS de tn-backfill-stamps en el frontend
// -- current_stamps tiene que reflejar ya cualquier compra retroactiva
// antes de decidir si esta persona "nunca compró".

const WELCOME_DISCOUNT_PERCENT = "5";
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

import { sendWelcomeCouponEmail } from "../_shared/notify.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "No autenticado" }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  // 1) Identificar al usuario logueado a partir de su propio token.
  const userRes = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: { apikey: serviceRoleKey, Authorization: authHeader },
  });
  if (!userRes.ok) return json({ error: "Sesión inválida" }, 401);
  const user = await userRes.json();

  // 2) Traer su fila de customers (con permisos de servicio).
  const custRes = await fetch(
    `${supabaseUrl}/rest/v1/customers?id=eq.${user.id}&select=id,email,display_name,current_stamps,welcome_coupon_sent`,
    { headers: svcHeaders }
  );
  const customer = (await custRes.json())?.[0];
  if (!customer) return json({ error: "Cliente no encontrado" }, 404);

  if (customer.welcome_coupon_sent) {
    return json({ ok: true, alreadySent: true }, 200);
  }

  // Marcar como enviado ya de entrada, para no reintentarlo en cada login
  // aunque algo falle a mitad de camino (mismo criterio que backfill_checked
  // en tn-backfill-stamps).
  await fetch(`${supabaseUrl}/rest/v1/customers?id=eq.${customer.id}`, {
    method: "PATCH",
    headers: svcHeaders,
    body: JSON.stringify({ welcome_coupon_sent: true }),
  });

  // Solo para quien todavía no tiene NINGUNA compra registrada.
  if (customer.current_stamps > 0) {
    return json({ ok: true, sent: false, reason: "ya tiene compras" }, 200);
  }

  // 3) Buscar la conexión con Tiendanube para crear el cupón real.
  const connRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?select=store_id,access_token&limit=1`,
    { headers: svcHeaders }
  );
  const conn = (await connRes.json())?.[0];
  if (!conn) {
    return json({ ok: true, sent: false, reason: "sin conexión con Tiendanube" }, 200);
  }

  const code = "BIENVENIDO5-" + randomSuffix();

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
      value: WELCOME_DISCOUNT_PERCENT,
      valid: true,
      max_uses: 1,
    }),
  });

  if (!couponRes.ok) {
    console.error("Error creando cupón de bienvenida:", couponRes.status, await couponRes.text());
    return json({ ok: true, sent: false, reason: "error creando cupón" }, 200);
  }

  // 4) Mandar el mail con el código real.
  const emailSent = await sendWelcomeCouponEmail({
    toEmail: customer.email,
    displayName: customer.display_name,
    code,
    percent: WELCOME_DISCOUNT_PERCENT,
    appUrl: Deno.env.get("APP_URL") || "http://localhost:8888",
  });

  console.log("Cupón de bienvenida:", customer.email, code, "mail enviado:", emailSent);
  return json({ ok: true, sent: emailSent, code }, 200);
});

function randomSuffix(): string {
  return Math.random().toString(36).slice(2, 8).toUpperCase();
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}
