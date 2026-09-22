// Baja de las campañas del Club. La llama el link del pie de cada campaña
// (GET, la persona hace clic) o el botón "Cancelar suscripción" del propio
// cliente de mail (POST de un solo clic, sin abrir nada -- Gmail y Outlook lo
// mandan solos gracias al header List-Unsubscribe-Post).
//
// verify_jwt = false a propósito: la llama gente sin sesión y el POST de Gmail
// no manda ninguna credencial. Lo que autoriza es la firma `t` del link, que
// sólo puede haber salido de campaign-send.
//
// OJO: dar de baja NO borra la cuenta ni corta los mails transaccionales
// (login, estrella, cupón). Esos son otra cosa y los pidió la persona al usar
// la app. Acá sólo se marca customers.unsubscribed = true.

Deno.serve(async (req: Request) => {
  if (req.method !== "GET" && req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const url = new URL(req.url);
  const email = (url.searchParams.get("e") || "").trim().toLowerCase();
  const token = (url.searchParams.get("t") || "").trim();

  if (!email || !token) return page("Link incompleto", "Faltan datos en el link. Escribinos y te damos de baja a mano.", 400);

  const secret = Deno.env.get("UNSUB_SECRET") || Deno.env.get("CRON_SECRET");
  if (!secret) {
    console.error("Falta UNSUB_SECRET/CRON_SECRET");
    return page("Algo salió mal", "No pudimos procesar la baja. Escribinos y lo hacemos a mano.", 500);
  }

  if ((await sign(email, secret)) !== token) {
    return page("Link inválido", "Este link no es válido o ya venció. Escribinos y te damos de baja a mano.", 403);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const res = await fetch(
    `${supabaseUrl}/rest/v1/customers?email=eq.${encodeURIComponent(email)}`,
    {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        apikey: serviceRoleKey,
        Authorization: `Bearer ${serviceRoleKey}`,
        Prefer: "return=minimal",
      },
      body: JSON.stringify({ unsubscribed: true }),
    },
  );

  if (!res.ok) {
    console.error("Error dando de baja:", res.status, await res.text());
    return page("Algo salió mal", "No pudimos procesar la baja. Escribinos y lo hacemos a mano.", 500);
  }

  // El POST de un solo clic no muestra nada: alcanza con un 200.
  if (req.method === "POST") return new Response(null, { status: 200 });

  return page(
    "Listo, te diste de baja",
    "No vas a recibir más novedades ni lanzamientos. Tu tarjeta del Club y tus estrellas siguen intactas, y vas a seguir recibiendo los mails de tu cuenta (ingreso, estrellas y premios).",
    200,
  );
});

async function sign(email: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(email.toLowerCase()));
  return Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("")
    .slice(0, 32);
}

function page(title: string, message: string, status: number): Response {
  const html = `<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${title} · Yokoo Club</title>
</head>
<body style="margin:0; padding:32px 20px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif; min-height:100vh; box-sizing:border-box;">
  <div style="max-width:420px; margin:0 auto;">
    <img src="https://givnsohzgsugvrfuftcm.supabase.co/storage/v1/object/public/assets/logo-yokoo-studio.png" width="190" alt="Yokoo Studio" style="display:block; margin:0 auto 22px; width:190px; height:auto; max-width:100%;" />
    <div style="background:#3a2115; border-radius:20px; padding:30px 26px; text-align:center;">
      <p style="margin:0 0 12px; color:#f6efa3; font-size:21px; font-weight:800; line-height:1.3;">${title}</p>
      <p style="margin:0; color:rgba(246,239,163,.85); font-size:15px; line-height:1.55;">${message}</p>
    </div>
  </div>
</body>
</html>`;
  return new Response(html, {
    status,
    headers: { "Content-Type": "text/html; charset=utf-8" },
  });
}
