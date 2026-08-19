// Tiendanube llama acá cuando se paga un pedido ("order/paid").
// Busca al cliente por el mail del pedido y le suma una estrella sola,
// sin pasar por aprobación manual.
//
// El payload que manda Tiendanube es chico -- { store_id, event, id } --
// así que hay que pedirle el pedido completo a su API para sacar el mail.

import { sendStampEmail } from "../_shared/notify.ts";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const rawBody = await req.text();
  let payload: { store_id?: number | string; id?: number | string; event?: string };
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return json({ ok: false, error: "JSON inválido" }, 400);
  }

  // Verificación de firma: Tiendanube firma el body crudo con HMAC-SHA256
  // usando el Client Secret de la app, codificado en hexadecimal, en el
  // header "x-linkedstore-hmac-sha256". Confirmado con un pedido real.
  const secret = Deno.env.get("TIENDANUBE_CLIENT_SECRET");
  const sigHeader = req.headers.get("x-linkedstore-hmac-sha256");
  if (!secret || !sigHeader || !(await verifyHmac(rawBody, secret, sigHeader))) {
    console.error("Firma de webhook inválida o ausente -- se rechaza el pedido.");
    return json({ ok: false, error: "Firma inválida" }, 401);
  }

  const storeId = String(payload.store_id ?? "");
  const orderId = String(payload.id ?? "");
  if (!storeId || !orderId) {
    return json({ ok: true, skipped: "payload incompleto" }, 200);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  // 1) Buscar el access_token guardado para esta tienda.
  const connRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?store_id=eq.${encodeURIComponent(storeId)}&select=access_token&limit=1`,
    { headers: svcHeaders }
  );
  const conn = (await connRes.json())?.[0];
  if (!conn) {
    console.error("No hay conexión guardada para store_id", storeId);
    return json({ ok: true, skipped: "tienda no conectada" }, 200);
  }

  // 2) Pedirle el pedido completo a Tiendanube para sacar el mail del cliente.
  const orderRes = await fetch(`https://api.tiendanube.com/v1/${storeId}/orders/${orderId}`, {
    headers: {
      Authentication: `bearer ${conn.access_token}`,
      "User-Agent": "Yokoo Club (jcdibastiano@gmail.com)",
    },
  });
  if (!orderRes.ok) {
    console.error("No se pudo leer el pedido", orderId, orderRes.status, await orderRes.text());
    return json({ ok: true, skipped: "no se pudo leer el pedido" }, 200);
  }
  const order = await orderRes.json();
  const email = String(order?.customer?.email || order?.contact_email || "").toLowerCase().trim();
  if (!email) {
    return json({ ok: true, skipped: "pedido sin mail" }, 200);
  }

  // 3) Buscar si ese mail está registrado en la tarjeta.
  const custRes = await fetch(
    `${supabaseUrl}/rest/v1/customers?email=eq.${encodeURIComponent(email)}&select=id,email,display_name,current_stamps`,
    { headers: svcHeaders }
  );
  const customer = (await custRes.json())?.[0];
  if (!customer) {
    return json({ ok: true, skipped: "cliente no registrado en la tarjeta" }, 200);
  }

  const goalRes = await fetch(`${supabaseUrl}/rest/v1/settings?key=eq.stamps_goal&select=value`, { headers: svcHeaders });
  const goal = parseInt((await goalRes.json())?.[0]?.value ?? "5", 10);

  // 4) Registrar el sello. El UNIQUE(source, order_id) de stamp_events evita
  // sumar dos veces si Tiendanube reintenta el mismo webhook.
  const insertRes = await fetch(`${supabaseUrl}/rest/v1/stamp_events`, {
    method: "POST",
    headers: { ...svcHeaders, Prefer: "return=minimal" },
    body: JSON.stringify({ customer_id: customer.id, source: "web_order", order_id: orderId }),
  });

  if (insertRes.status === 409) {
    return json({ ok: true, skipped: "pedido ya procesado antes" }, 200);
  }
  if (!insertRes.ok) {
    console.error("Error insertando stamp_event", insertRes.status, await insertRes.text());
    return json({ ok: false }, 500);
  }

  var newStamps = customer.current_stamps;
  if (customer.current_stamps < goal) {
    newStamps = customer.current_stamps + 1;
    await fetch(`${supabaseUrl}/rest/v1/customers?id=eq.${customer.id}`, {
      method: "PATCH",
      headers: svcHeaders,
      body: JSON.stringify({ current_stamps: newStamps }),
    });
  }

  await sendStampEmail({
    toEmail: customer.email,
    displayName: customer.display_name,
    currentStamps: newStamps,
    goal,
    appUrl: Deno.env.get("APP_URL") || "http://localhost:8888",
  });

  console.log("Estrella sumada por compra web:", email, "pedido", orderId);
  return json({ ok: true, customer: email }, 200);
});

async function verifyHmac(rawBody: string, secret: string, signatureHex: string): Promise<boolean> {
  try {
    const enc = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      enc.encode(secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const sigBuf = await crypto.subtle.sign("HMAC", key, enc.encode(rawBody));
    const computed = Array.from(new Uint8Array(sigBuf))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
    return computed.toLowerCase() === signatureHex.toLowerCase();
  } catch {
    return false;
  }
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
