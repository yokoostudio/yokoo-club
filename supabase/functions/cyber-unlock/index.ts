// Registro al Club desde la tienda, con acceso inmediato al Cyber.
//
// La llama la barra del storefront (snipplets/yk-cyber-gate.tpl). Recibe un
// mail y hace tres cosas:
//   1. crea la cuenta del Club si no existe (el trigger de la base crea
//      además la fila en customers),
//   2. le manda el mail con su link de ingreso, que le verifica la cuenta y
//      le deja la tarjeta andando,
//   3. devuelve la URL del Cyber para que la persona entre YA, en la misma
//      sesión, sin esperar ningún correo.
//
// verify_jwt = false: la llama gente sin sesión, desde el navegador. Al estar
// abierta a internet y mandar mails, el freno contra abuso es lo más
// importante de este archivo (ver LIMITES más abajo).

import { sendInviteEmail } from "../_shared/notify.ts";

// Desde dónde se acepta la llamada. Cualquier otro origen se rechaza: evita
// que alguien monte un formulario en otro sitio y use esto para mandar correo.
const ORIGENES_OK = [
  "https://www.yokoo.com.ar",
  "https://yokoo.com.ar",
  "https://yokoo.mitiendanube.com",
];

// LIMITES de uso. Son deliberadamente holgados para una persona real y
// estrechos para un script.
const MAX_POR_EMAIL_10MIN = 1;
const MAX_POR_IP_HORA = 8;
const MAX_GLOBAL_HORA = 300;

Deno.serve(async (req: Request) => {
  const origen = req.headers.get("origin") || "";
  const permitido = ORIGENES_OK.includes(origen);
  const cors: Record<string, string> = {
    "Access-Control-Allow-Origin": permitido ? origen : ORIGENES_OK[0],
    "Access-Control-Allow-Headers": "content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Vary": "Origin",
  };

  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, cors);
  if (origen && !permitido) return json({ error: "Origen no permitido" }, 403, cors);

  let email = "";
  try {
    const body = await req.json();
    email = String(body?.email || "").trim().toLowerCase();
  } catch {
    return json({ error: "Falta el mail" }, 400, cors);
  }

  // Validación deliberadamente simple: lo que importa es descartar basura
  // evidente. Si el mail no existe de verdad, el correo rebota y listo.
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email) || email.length > 150) {
    return json({ error: "Ese mail no parece válido" }, 400, cors);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const resendKey = Deno.env.get("RESEND_API_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  const cyberUrl = Deno.env.get("CYBER_URL") || "https://www.yokoo.com.ar/";
  const appUrl = (Deno.env.get("APP_URL") || "https://yokoostudio.github.io/yokoo-club/").replace(/\/+$/, "");

  const ipHash = await hash(
    (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "sin-ip",
  );

  // --- frenos de abuso ------------------------------------------------------
  const hace10 = new Date(Date.now() - 10 * 60e3).toISOString();
  const haceHora = new Date(Date.now() - 60 * 60e3).toISOString();

  const contar = async (filtro: string): Promise<number> => {
    const r = await fetch(`${supabaseUrl}/rest/v1/gate_requests?select=id&${filtro}`, {
      headers: { ...svcHeaders, Prefer: "count=exact", Range: "0-0" },
    });
    const cr = r.headers.get("content-range") || "";
    const total = parseInt(cr.split("/")[1] || "0", 10);
    return Number.isNaN(total) ? 0 : total;
  };

  const [porEmail, porIp, globales] = await Promise.all([
    contar(`email=eq.${encodeURIComponent(email)}&created_at=gte.${hace10}`),
    contar(`ip_hash=eq.${ipHash}&created_at=gte.${haceHora}`),
    contar(`created_at=gte.${haceHora}`),
  ]);

  if (globales >= MAX_GLOBAL_HORA) {
    console.error("Freno global de cyber-unlock alcanzado");
    return json({ error: "Estamos recibiendo muchos registros. Probá en unos minutos." }, 429, cors);
  }
  if (porIp >= MAX_POR_IP_HORA) {
    return json({ error: "Demasiados intentos. Probá más tarde." }, 429, cors);
  }

  // Si ya pidió hace menos de 10 minutos, NO se le manda otro mail -- pero sí
  // se le devuelve el acceso: tocar el botón dos veces es algo que hace una
  // persona normal, y dejarla afuera por eso sería absurdo.
  const repetido = porEmail >= MAX_POR_EMAIL_10MIN;

  await fetch(`${supabaseUrl}/rest/v1/gate_requests`, {
    method: "POST",
    headers: { ...svcHeaders, Prefer: "return=minimal" },
    body: JSON.stringify({ email, ip_hash: ipHash }),
  });

  if (repetido) {
    return json({ ok: true, url: cyberUrl, mailEnviado: false }, 200, cors);
  }

  // --- cuenta + mail --------------------------------------------------------
  // generate_link crea el usuario si no existe y NO manda ningún correo: el
  // mail lo mandamos nosotros, con la estética de la marca.
  // Ojo (ya nos mordió en agosto): action_link viene en la RAÍZ de la
  // respuesta, no bajo properties; y redirect_to va en el primer nivel del
  // body, no dentro de options -- si se manda adentro, se ignora en silencio.
  let magicLink = "";
  try {
    const r = await fetch(`${supabaseUrl}/auth/v1/admin/generate_link`, {
      method: "POST",
      headers: svcHeaders,
      body: JSON.stringify({ type: "magiclink", email, redirect_to: appUrl }),
    });
    if (r.ok) {
      const d = await r.json();
      magicLink = d?.action_link || d?.properties?.action_link || "";
    } else {
      console.error("generate_link falló", r.status, await r.text());
    }
  } catch (e) {
    console.error("Excepción en generate_link", e);
  }

  // El acceso al Cyber se devuelve igual aunque el mail falle: la persona ya
  // dejó su dato y lo que quiere es entrar. El correo es un extra.
  if (magicLink) {
    await sendInviteEmail({ toEmail: email, displayName: null, magicLink });
  }

  return json({ ok: true, url: cyberUrl, mailEnviado: !!magicLink }, 200, cors);
});

async function hash(valor: string): Promise<string> {
  const b = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(valor));
  return Array.from(new Uint8Array(b)).map((x) => x.toString(16).padStart(2, "0")).join("").slice(0, 32);
}

function json(body: unknown, status: number, cors: Record<string, string>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
