// Suma un sello directo a un cliente por mail (acción de Negocio) y avisa
// por mail. Reemplaza la llamada directa al RPC desde el frontend.

import { sendStampEmail } from "../_shared/notify.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "No autenticado" }, 401);

  let body: { email?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Body inválido" }, 400);
  }
  const email = (body.email || "").toLowerCase().trim();
  if (!email) return json({ error: "Falta email" }, 400);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  // 1) Sumar el sello como el usuario logueado (exige is_staff() del lado del RPC).
  const rpcRes = await fetch(`${supabaseUrl}/rest/v1/rpc/add_direct_stamp`, {
    method: "POST",
    headers: { "Content-Type": "application/json", apikey: anonKey, Authorization: authHeader },
    body: JSON.stringify({ p_email: email }),
  });
  if (!rpcRes.ok) {
    const err = await rpcRes.json().catch(() => ({}));
    return json({ error: err.message || "No se pudo sumar el sello" }, 400);
  }

  // 2) Mandar el mail de aviso.
  const custRes = await fetch(
    `${supabaseUrl}/rest/v1/customers?email=eq.${encodeURIComponent(email)}&select=email,display_name,current_stamps`,
    { headers: svcHeaders }
  );
  const customer = (await custRes.json())?.[0];

  if (customer) {
    const goalRes = await fetch(`${supabaseUrl}/rest/v1/settings?key=eq.stamps_goal&select=value`, { headers: svcHeaders });
    const goal = parseInt((await goalRes.json())?.[0]?.value ?? "5", 10);

    await sendStampEmail({
      toEmail: customer.email,
      displayName: customer.display_name,
      currentStamps: customer.current_stamps,
      goal,
      appUrl: Deno.env.get("APP_URL") || "http://localhost:8888",
    });
  }

  return json({ ok: true }, 200);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}
