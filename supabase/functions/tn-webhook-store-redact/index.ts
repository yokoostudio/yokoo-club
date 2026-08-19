// Webhook obligatorio de Tiendanube: "store/redact"
// Tiendanube lo llama cuando una tienda desinstala la app y pasó el
// tiempo de gracia -- hay que borrar cualquier dato guardado de esa tienda.
//
// Por ahora: registra el pedido y responde 200. La lógica real de borrado
// se completa antes de tener clientes reales conectados de verdad.

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  let payload: unknown = null;
  try {
    payload = await req.json();
  } catch {
    // cuerpo vacío o no-JSON, lo ignoramos
  }

  console.log("tn-webhook-store-redact recibido:", JSON.stringify(payload));

  // TODO antes de producción: borrar public.tiendanube_connection
  // y cualquier otro dato ligado a store_id (payload.store_id).

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
