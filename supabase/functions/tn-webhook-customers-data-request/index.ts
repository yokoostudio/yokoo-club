// Webhook obligatorio de Tiendanube: "customers/data_request"
// Tiendanube lo llama cuando un cliente pide una copia de los datos que
// tenemos guardados sobre él.
//
// Por ahora: registra el pedido y responde 200. La lógica real (armar y
// enviar el reporte de datos) se completa antes de tener clientes reales.

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

  console.log("tn-webhook-customers-data-request recibido:", JSON.stringify(payload));

  // TODO antes de producción: juntar los datos del cliente (customers,
  // stamp_events, redemptions) y enviárselos por el canal que Tiendanube
  // indique en su documentación.

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
