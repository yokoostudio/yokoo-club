// Webhook obligatorio de Tiendanube: "store/redact"
// Tiendanube lo llama cuando una tienda desinstala la app y pasó el
// tiempo de gracia -- hay que borrar cualquier dato guardado de esa tienda.
//
// Lo único que guardamos ligado a una tienda (no a un cliente) es su
// conexión (access_token) en tiendanube_connection -- eso es lo que se borra.

import { verifyTiendanubeHmac } from "../_shared/tiendanube.ts";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const rawBody = await req.text();
  let payload: { store_id?: number | string };
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return json({ ok: false, error: "JSON inválido" }, 400);
  }

  const secret = Deno.env.get("TIENDANUBE_CLIENT_SECRET");
  const sigHeader = req.headers.get("x-linkedstore-hmac-sha256");
  if (!secret || !sigHeader || !(await verifyTiendanubeHmac(rawBody, secret, sigHeader))) {
    console.error("Firma de webhook inválida o ausente -- se rechaza store/redact.");
    return json({ ok: false, error: "Firma inválida" }, 401);
  }

  const storeId = String(payload.store_id ?? "");
  if (!storeId) {
    return json({ ok: true, skipped: "payload sin store_id" }, 200);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  const delRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?store_id=eq.${encodeURIComponent(storeId)}`,
    { method: "DELETE", headers: svcHeaders }
  );

  if (!delRes.ok) {
    console.error("Error borrando tiendanube_connection", delRes.status, await delRes.text());
    return json({ ok: false }, 500);
  }

  console.log("store/redact procesado para store_id:", storeId);
  return json({ ok: true }, 200);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
