// Se llama una vez, la primera vez que un cliente entra a la tarjeta.
// Revisa sus compras pagadas de los últimos 30 días en Tiendanube y le
// suma retroactivamente los sellos que se haya perdido por no estar
// registrado todavía en el momento de comprar.
//
// Corre como el propio usuario logueado (verify_jwt = true), pero después
// usa la llave de servicio para las escrituras -- respeta igual la sesión
// real: solo puede hacer el backfill de SU PROPIA cuenta.

const BACKFILL_DAYS = 30;
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

import { sendStampEmail } from "../_shared/notify.ts";

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
    `${supabaseUrl}/rest/v1/customers?id=eq.${user.id}&select=id,email,display_name,current_stamps,backfill_checked`,
    { headers: svcHeaders }
  );
  const customer = (await custRes.json())?.[0];
  if (!customer) return json({ error: "Cliente no encontrado" }, 404);

  if (customer.backfill_checked) {
    return json({ ok: true, alreadyChecked: true, added: 0 }, 200);
  }

  // Marcar como revisado ya de entrada, para no reintentarlo en cada login
  // aunque algo falle a mitad de camino.
  await fetch(`${supabaseUrl}/rest/v1/customers?id=eq.${customer.id}`, {
    method: "PATCH",
    headers: svcHeaders,
    body: JSON.stringify({ backfill_checked: true }),
  });

  // 3) Buscar la conexión con Tiendanube.
  const connRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?select=store_id,access_token&limit=1`,
    { headers: svcHeaders }
  );
  const conn = (await connRes.json())?.[0];
  if (!conn) {
    return json({ ok: true, added: 0, note: "sin conexión con Tiendanube" }, 200);
  }

  const sinceDate = new Date(Date.now() - BACKFILL_DAYS * 24 * 60 * 60 * 1000).toISOString();
  const tnHeaders = {
    Authentication: `bearer ${conn.access_token}`,
    "User-Agent": "Yokoo Club (jcdibastiano@gmail.com)",
  };

  // 4) El orden en que Tiendanube devuelve los pedidos no es confiable
  // (no es ni claramente ascendente ni descendente por fecha), y
  // "created_at_min" tampoco filtra bien -- así que recorremos TODAS las
  // páginas de pedidos pagados (con un tope generoso) y filtramos la
  // fecha nosotros mismos comparando cada pedido.
  const PAGE_SIZE = 200;
  const MAX_PAGES = 15; // hasta 3000 pedidos revisados -- cubre la tienda entera con margen

  const matchedOrderIds: string[] = [];
  const email = customer.email.toLowerCase();
  const sinceMs = Date.parse(sinceDate);

  for (let page = 1; page <= MAX_PAGES; page++) {
    const ordersUrl = `https://api.tiendanube.com/v1/${conn.store_id}/orders?payment_status=paid&per_page=${PAGE_SIZE}&page=${page}`;
    const ordersRes = await fetch(ordersUrl, { headers: tnHeaders });
    if (!ordersRes.ok) {
      console.error("Error listando pedidos", ordersRes.status, await ordersRes.text());
      break;
    }
    const orders = await ordersRes.json();
    if (!Array.isArray(orders) || orders.length === 0) break;

    for (const order of orders) {
      const createdMs = Date.parse(order?.created_at ?? "");
      if (isNaN(createdMs) || createdMs < sinceMs) continue;
      const orderEmail = String(order?.customer?.email || order?.contact_email || "").toLowerCase();
      if (orderEmail === email) {
        matchedOrderIds.push(String(order.id));
      }
    }

    if (orders.length < PAGE_SIZE) break; // última página
  }

  if (matchedOrderIds.length === 0) {
    return json({ ok: true, added: 0 }, 200);
  }

  // 5) Insertar un stamp_event por cada pedido encontrado. El UNIQUE(source,
  // order_id) evita duplicar si alguno ya había sido sumado por el webhook.
  let added = 0;
  for (const orderId of matchedOrderIds) {
    const insertRes = await fetch(`${supabaseUrl}/rest/v1/stamp_events`, {
      method: "POST",
      headers: { ...svcHeaders, Prefer: "return=minimal" },
      body: JSON.stringify({ customer_id: customer.id, source: "web_order", order_id: orderId }),
    });
    if (insertRes.ok) added++;
  }

  if (added === 0) {
    return json({ ok: true, added: 0 }, 200);
  }

  // 6) Sumar las estrellas correspondientes, sin pasarse de la meta.
  const goalRes = await fetch(`${supabaseUrl}/rest/v1/settings?key=eq.stamps_goal&select=value`, { headers: svcHeaders });
  const goal = parseInt((await goalRes.json())?.[0]?.value ?? "5", 10);
  const newStamps = Math.min(customer.current_stamps + added, goal);

  await fetch(`${supabaseUrl}/rest/v1/customers?id=eq.${customer.id}`, {
    method: "PATCH",
    headers: svcHeaders,
    body: JSON.stringify({ current_stamps: newStamps }),
  });

  await sendStampEmail({
    toEmail: customer.email,
    displayName: customer.display_name,
    currentStamps: newStamps,
    goal,
    appUrl: Deno.env.get("APP_URL") || "http://localhost:8888",
  });

  console.log("Backfill:", email, "pedidos encontrados:", matchedOrderIds.length, "sellos sumados:", added);
  return json({ ok: true, added }, 200);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}
