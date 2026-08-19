// Webhook obligatorio de Tiendanube: "customers/redact"
// Tiendanube lo llama cuando un cliente de la tienda pide que se borren
// sus datos personales.
//
// Borramos su cuenta de login (auth.users) -- como todas nuestras tablas
// (customers, stamp_events, stamp_requests, redemptions) tienen "on delete
// cascade" hacia auth.users, con un solo borrado se limpia todo su rastro.

import { verifyTiendanubeHmac } from "../_shared/tiendanube.ts";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const rawBody = await req.text();
  let payload: { customer?: { email?: string; id?: number | string } };
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return json({ ok: false, error: "JSON inválido" }, 400);
  }

  const secret = Deno.env.get("TIENDANUBE_CLIENT_SECRET");
  const sigHeader = req.headers.get("x-linkedstore-hmac-sha256");
  if (!secret || !sigHeader || !(await verifyTiendanubeHmac(rawBody, secret, sigHeader))) {
    console.error("Firma de webhook inválida o ausente -- se rechaza customers/redact.");
    return json({ ok: false, error: "Firma inválida" }, 401);
  }

  const email = String(payload.customer?.email || "").toLowerCase().trim();
  if (!email) {
    return json({ ok: true, skipped: "payload sin mail de cliente" }, 200);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  // 1) Por las dudas, borrar también cualquier invitación pendiente guardada
  // con ese mail (no depende de que esté registrado).
  await fetch(`${supabaseUrl}/rest/v1/pending_invites?email=eq.${encodeURIComponent(email)}`, {
    method: "DELETE",
    headers: svcHeaders,
  });

  // 2) Buscar si ese mail está registrado en la tarjeta.
  const custRes = await fetch(
    `${supabaseUrl}/rest/v1/customers?email=eq.${encodeURIComponent(email)}&select=id`,
    { headers: svcHeaders }
  );
  const customer = (await custRes.json())?.[0];
  if (!customer) {
    return json({ ok: true, skipped: "cliente no registrado en la tarjeta" }, 200);
  }

  // 3) Borrar la cuenta de auth -- cascada a todo lo demás.
  const delRes = await fetch(`${supabaseUrl}/auth/v1/admin/users/${customer.id}`, {
    method: "DELETE",
    headers: svcHeaders,
  });

  if (!delRes.ok) {
    console.error("Error borrando el usuario de auth", delRes.status, await delRes.text());
    return json({ ok: false }, 500);
  }

  console.log("customers/redact procesado para:", email);
  return json({ ok: true }, 200);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
