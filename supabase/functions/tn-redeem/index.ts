// Canjea el premio del cliente logueado y, si el premio actual tiene
// formato de porcentaje (ej. "40% OFF"), crea además un cupón real en
// Tiendanube con el mismo código -- así sirve tanto en el local como
// en la tienda web.

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "No autenticado" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // 1) Canjear el premio como el usuario logueado (respeta auth.uid() y RLS).
  const rpcRes = await fetch(`${supabaseUrl}/rest/v1/rpc/redeem_reward`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: anonKey,
      Authorization: authHeader,
    },
    body: JSON.stringify({}),
  });

  if (!rpcRes.ok) {
    const errBody = await rpcRes.json().catch(() => ({}));
    return json({ error: errBody.message || "No se pudo canjear" }, 400);
  }

  const code: string = await rpcRes.json();

  // 2) Buscar el canje recién creado (con permisos de servicio).
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  const redemptionRes = await fetch(
    `${supabaseUrl}/rest/v1/redemptions?redemption_code=eq.${encodeURIComponent(code)}&select=id,reward_text`,
    { headers: svcHeaders }
  );
  const redemptionRows = await redemptionRes.json();
  const redemption = redemptionRows?.[0];

  let webCouponCreated = false;

  const percentMatch = redemption?.reward_text?.match(/(\d{1,3})\s*%/);

  if (percentMatch) {
    webCouponCreated = await tryCreateTiendanubeCoupon({
      supabaseUrl,
      svcHeaders,
      code,
      percentValue: percentMatch[1],
      redemptionId: redemption.id,
    });
  }

  return json({ code, webCouponCreated }, 200);
});

async function tryCreateTiendanubeCoupon(opts: {
  supabaseUrl: string;
  svcHeaders: Record<string, string>;
  code: string;
  percentValue: string;
  redemptionId: string;
}): Promise<boolean> {
  const { supabaseUrl, svcHeaders, code, percentValue, redemptionId } = opts;

  try {
    const connRes = await fetch(
      `${supabaseUrl}/rest/v1/tiendanube_connection?select=store_id,access_token&limit=1`,
      { headers: svcHeaders }
    );
    const connRows = await connRes.json();
    const conn = connRows?.[0];
    if (!conn) {
      console.error("No hay conexión con Tiendanube guardada todavía.");
      return false;
    }

    const couponRes = await fetch(
      `https://api.tiendanube.com/v1/${conn.store_id}/coupons`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authentication: `bearer ${conn.access_token}`,
          "User-Agent": "Yokoo Club (jcdibastiano@gmail.com)",
        },
        body: JSON.stringify({
          code,
          type: "percentage",
          value: percentValue,
          valid: true,
          max_uses: 1,
        }),
      }
    );

    if (!couponRes.ok) {
      console.error("Error creando cupón en Tiendanube:", couponRes.status, await couponRes.text());
      return false;
    }

    await fetch(`${supabaseUrl}/rest/v1/redemptions?id=eq.${redemptionId}`, {
      method: "PATCH",
      headers: svcHeaders,
      body: JSON.stringify({ tiendanube_coupon_created: true }),
    });

    return true;
  } catch (e) {
    console.error("Excepción creando cupón en Tiendanube:", e);
    return false;
  }
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}
