// Webhook obligatorio de Tiendanube: "customers/redact"
// Tiendanube lo llama cuando un cliente de la tienda pide que se borren
// sus datos personales.
//
// Por ahora: registra el pedido y responde 200. La lógica real de borrado
// (anonimizar su fila en customers, o eliminarla) se completa antes de
// tener clientes reales conectados de verdad.

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

  console.log("tn-webhook-customers-redact recibido:", JSON.stringify(payload));

  // TODO antes de producción: buscar al cliente por email/id de Tiendanube
  // en public.customers y anonimizar o borrar su información.

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
