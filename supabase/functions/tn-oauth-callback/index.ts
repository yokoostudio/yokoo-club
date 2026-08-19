// Recibe al dueño de la tienda después de instalar/autorizar la app en
// Tiendanube. Tiendanube redirige acá con ?code=... en la URL; lo
// intercambiamos por un access_token real de la tienda y lo guardamos.

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const code = url.searchParams.get("code");

  if (!code) {
    return html("Falta el código de autorización en la URL.", true, 400);
  }

  const clientId = Deno.env.get("TIENDANUBE_CLIENT_ID");
  const clientSecret = Deno.env.get("TIENDANUBE_CLIENT_SECRET");

  if (!clientId || !clientSecret) {
    console.error("Faltan los secrets TIENDANUBE_CLIENT_ID / TIENDANUBE_CLIENT_SECRET.");
    return html("Configuración incompleta del lado del servidor.", true, 500);
  }

  const tokenRes = await fetch("https://www.tiendanube.com/apps/authorize/token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: clientId,
      client_secret: clientSecret,
      grant_type: "authorization_code",
      code,
    }),
  });

  if (!tokenRes.ok) {
    console.error("Error intercambiando el código:", tokenRes.status, await tokenRes.text());
    return html("No se pudo completar la conexión con Tiendanube.", true, 502);
  }

  const tokenData = await tokenRes.json();
  // tokenData: { access_token, token_type, scope, user_id }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const saveRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?on_conflict=store_id`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: serviceRoleKey,
        Authorization: `Bearer ${serviceRoleKey}`,
        Prefer: "resolution=merge-duplicates",
      },
      body: JSON.stringify({
        store_id: String(tokenData.user_id),
        access_token: tokenData.access_token,
      }),
    }
  );

  if (!saveRes.ok) {
    console.error("Error guardando la conexión:", saveRes.status, await saveRes.text());
    return html("Se conectó con Tiendanube pero no pudimos guardar el acceso. Avisale a Juan.", true, 500);
  }

  console.log("Tienda conectada, store_id:", tokenData.user_id);
  return html("¡Listo! Tiendanube quedó conectada con Yokoo.", false, 200);
});

function html(message: string, isError: boolean, status: number) {
  // Nota: el gateway de Supabase fuerza "text/plain" en esta función sin
  // importar el Content-Type que declaremos, así que devolvemos texto plano
  // prolijo en vez de HTML con tags visibles sin estilo.
  const body = `${isError ? "⚠️" : "✅"} Yokoo × Tiendanube\n\n${message}`;
  const headers = new Headers();
  headers.set("Content-Type", "text/plain; charset=utf-8");
  return new Response(body, { status, headers });
}
