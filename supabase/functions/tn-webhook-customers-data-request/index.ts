// Webhook obligatorio de Tiendanube: "customers/data_request"
// Tiendanube lo llama cuando un cliente pide una copia de los datos que
// tenemos guardados sobre él.
//
// No tenemos un flujo de autoservicio para entregarle los datos directo al
// cliente, así que juntamos todo lo que tenemos y se lo mandamos por mail
// al dueño del negocio, para que se lo reenvíe por su canal habitual.

import { sendDataRequestReport } from "../_shared/notify.ts";
import { verifyTiendanubeHmac } from "../_shared/tiendanube.ts";

const OWNER_EMAIL = "jcdibastiano@gmail.com";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const rawBody = await req.text();
  let payload: { customer?: { email?: string } };
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return json({ ok: false, error: "JSON inválido" }, 400);
  }

  const secret = Deno.env.get("TIENDANUBE_CLIENT_SECRET");
  const sigHeader = req.headers.get("x-linkedstore-hmac-sha256");
  if (!secret || !sigHeader || !(await verifyTiendanubeHmac(rawBody, secret, sigHeader))) {
    console.error("Firma de webhook inválida o ausente -- se rechaza customers/data_request.");
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

  const custRes = await fetch(
    `${supabaseUrl}/rest/v1/customers?email=eq.${encodeURIComponent(email)}&select=*`,
    { headers: svcHeaders }
  );
  const customer = (await custRes.json())?.[0];
  if (!customer) {
    return json({ ok: true, skipped: "cliente no registrado en la tarjeta" }, 200);
  }

  const [eventsRes, requestsRes, redemptionsRes] = await Promise.all([
    fetch(`${supabaseUrl}/rest/v1/stamp_events?customer_id=eq.${customer.id}&select=source,order_id,created_at&order=created_at.asc`, { headers: svcHeaders }),
    fetch(`${supabaseUrl}/rest/v1/stamp_requests?customer_id=eq.${customer.id}&select=status,requested_at,resolved_at&order=requested_at.asc`, { headers: svcHeaders }),
    fetch(`${supabaseUrl}/rest/v1/redemptions?customer_id=eq.${customer.id}&select=reward_text,redemption_code,redeemed_at,claimed_at&order=redeemed_at.asc`, { headers: svcHeaders }),
  ]);
  const events = await eventsRes.json();
  const requests = await requestsRes.json();
  const redemptions = await redemptionsRes.json();

  const reportText = [
    `Datos guardados en la tarjeta Yokoo para: ${email}`,
    ``,
    `Cliente:`,
    JSON.stringify(customer, null, 2),
    ``,
    `Historial de sellos (${events.length}):`,
    JSON.stringify(events, null, 2),
    ``,
    `Solicitudes de sello (${requests.length}):`,
    JSON.stringify(requests, null, 2),
    ``,
    `Canjes de premio (${redemptions.length}):`,
    JSON.stringify(redemptions, null, 2),
  ].join("\n");

  await sendDataRequestReport({ ownerEmail: OWNER_EMAIL, customerEmail: email, reportText });

  console.log("customers/data_request procesado para:", email);
  return json({ ok: true }, 200);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
