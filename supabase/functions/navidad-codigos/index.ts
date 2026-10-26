// Códigos de Navidad para quien compró en el CyberYokoo.
//
// Corre el sábado 7/11 a la mañana (pg_cron) y, por cada persona que compró
// entre el 31/10 y el 4/11: crea un cupón único en Tiendanube con vigencia
// hasta el 7/12 y se lo manda por mail con el código adentro.
//
// No usa el sistema de campañas a propósito: ahí todos reciben el mismo
// texto, y acá cada persona recibe un código distinto.
//
// Juan viaja el 3/11, así que esto tiene que quedar probado antes y correr
// solo. Por eso además manda un reporte al dueño cuando termina.
//
// verify_jwt = false; se protege con CAMPAIGN_SECRET igual que el resto.

import { sendNavidadCodeEmail, sendNavidadReport } from "../_shared/notify.ts";

const OWNER_EMAIL = "jcdibastiano@gmail.com";
const PORCENTAJE = 25;
const VENCE = "2026-12-07";
const VENCE_TEXTO = "7 de diciembre";
const TIENDA_URL = "https://www.yokoo.com.ar/";

// Ventana del Cyber, en UTC (Argentina es UTC-3).
const CYBER_DESDE = "2026-10-31T03:00:00Z";
const CYBER_HASTA = "2026-11-05T02:59:59Z";

// Tope por corrida: si algo sale mal, que no se desborde en un solo golpe.
// Con volver a correr la función se siguen los que falten.
const MAX_POR_CORRIDA = 200;

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const campaignSecret = Deno.env.get("CAMPAIGN_SECRET");
  const cronSecret = Deno.env.get("CRON_SECRET");
  const given = req.headers.get("x-yokoo-cron-secret");
  if (!((campaignSecret && given === campaignSecret) || (cronSecret && given === cronSecret))) {
    return json({ error: "No autorizado" }, 401);
  }

  let dryRun = false;
  let testEmail = "";
  try {
    const body = await req.json();
    dryRun = body?.dryRun === true;
    testEmail = String(body?.testEmail || "").trim().toLowerCase();
  } catch {
    // sin body: corrida normal (así la llama el cron)
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const resendKey = Deno.env.get("RESEND_API_KEY")!;
  const svcHeaders = {
    "Content-Type": "application/json",
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  // --- 0) Modo prueba -------------------------------------------------------
  // Va ANTES de buscar compradores a propósito: hasta que el Cyber no pase no
  // hay ninguno, y necesitamos poder probar el circuito completo (cupón real
  // con vencimiento + mail) desde hoy. Si esto estuviera más abajo, la función
  // saldría por "nadie compró" y nunca se probaría nada.
  if (testEmail) {
    const conn = await traerConexion(supabaseUrl, svcHeaders);
    if (!conn) return json({ error: "Sin conexión con Tiendanube" }, 500);

    const code = "YOKOONAVIDAD-" + sufijo();
    const r = await crearCupon(conn, code);
    if (!r.ok) {
      return json({ error: "No se pudo crear el cupón", status: r.status, detalle: r.detalle }, 500);
    }

    const mandado = await sendNavidadCodeEmail({
      apiKey: resendKey,
      toEmail: testEmail,
      displayName: "Prueba",
      code,
      percent: PORCENTAJE,
      hasta: VENCE_TEXTO,
      tiendaUrl: TIENDA_URL,
    });

    return json({ ok: true, modo: "test", code, cuponCreado: true, mailEnviado: mandado, vence: VENCE }, 200);
  }

  // --- 1) Quiénes compraron en el Cyber ------------------------------------
  // Dos consultas en vez de una: la marca `cyber_bonus` sólo se crea para
  // pedidos dentro de la ventana, así que vale siempre, aunque la estrella se
  // haya registrado más tarde (alguien que compró sin cuenta y se registró
  // después). La segunda cubre el caso raro de que el bonus haya fallado.
  const [bonusRes, webRes] = await Promise.all([
    fetch(`${supabaseUrl}/rest/v1/stamp_events?select=customer_id&source=eq.cyber_bonus`, { headers: svcHeaders }),
    fetch(
      `${supabaseUrl}/rest/v1/stamp_events?select=customer_id&source=eq.web_order` +
        `&created_at=gte.${encodeURIComponent(CYBER_DESDE)}&created_at=lte.${encodeURIComponent(CYBER_HASTA)}`,
      { headers: svcHeaders },
    ),
  ]);
  if (!bonusRes.ok || !webRes.ok) {
    console.error("Error leyendo stamp_events", bonusRes.status, webRes.status);
    return json({ error: "No se pudo leer quién compró" }, 500);
  }
  const ids = new Set<string>();
  for (const r of (await bonusRes.json()) as { customer_id: string }[]) ids.add(r.customer_id);
  for (const r of (await webRes.json()) as { customer_id: string }[]) ids.add(r.customer_id);

  if (ids.size === 0) {
    return json({ ok: true, enviados: 0, mensaje: "Nadie compró en la ventana del Cyber" }, 200);
  }

  // --- 2) Sacar a quienes ya lo recibieron ---------------------------------
  const yaRes = await fetch(`${supabaseUrl}/rest/v1/navidad_codigos?select=customer_id`, { headers: svcHeaders });
  const yaTienen = new Set<string>(
    yaRes.ok ? ((await yaRes.json()) as { customer_id: string }[]).map((r) => r.customer_id) : [],
  );
  const pendientes = [...ids].filter((id) => !yaTienen.has(id));

  if (pendientes.length === 0) {
    return json({ ok: true, enviados: 0, yaTenian: yaTienen.size, mensaje: "Ya lo recibieron todos" }, 200);
  }

  // --- 3) Datos de esas personas -------------------------------------------
  const lista = pendientes.slice(0, MAX_POR_CORRIDA);
  const custRes = await fetch(
    `${supabaseUrl}/rest/v1/customers?select=id,email,display_name&unsubscribed=is.false&id=in.(${lista.join(",")})`,
    { headers: svcHeaders },
  );
  if (!custRes.ok) {
    console.error("Error leyendo customers", custRes.status, await custRes.text());
    return json({ error: "No se pudo leer los clientes" }, 500);
  }
  const clientes = (await custRes.json()) as { id: string; email: string; display_name: string | null }[];

  if (dryRun) {
    return json(
      {
        ok: true,
        dryRun: true,
        compraronEnElCyber: ids.size,
        yaTenian: yaTienen.size,
        seLesMandaria: clientes.length,
        muestra: clientes.slice(0, 5).map((c) => maskEmail(c.email)),
      },
      200,
    );
  }

  // --- 4) Conexión con Tiendanube ------------------------------------------
  const connRes = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?select=store_id,access_token&limit=1`,
    { headers: svcHeaders },
  );
  const conn = (await connRes.json())?.[0];
  if (!conn) return json({ error: "Sin conexión con Tiendanube" }, 500);

  // --- 5) Un cupón y un mail por persona -----------------------------------
  let enviados = 0;
  let fallidos = 0;

  for (const c of clientes) {
    const code = "YOKOONAVIDAD-" + sufijo();

    const cup = await crearCupon(conn, code);
    if (!cup.ok) {
      fallidos++;
      continue;
    }

    const ok = await sendNavidadCodeEmail({
      apiKey: resendKey,
      toEmail: c.email,
      displayName: c.display_name,
      code,
      percent: PORCENTAJE,
      hasta: VENCE_TEXTO,
      tiendaUrl: TIENDA_URL,
    });

    if (!ok) {
      // El cupón ya existe pero el mail no salió. Se registra como fallido y
      // NO se marca como entregado, así un reintento le manda uno nuevo.
      console.error("Cupón creado pero el mail falló:", c.email);
      fallidos++;
      continue;
    }

    await fetch(`${supabaseUrl}/rest/v1/navidad_codigos`, {
      method: "POST",
      headers: { ...svcHeaders, Prefer: "return=minimal,resolution=ignore-duplicates" },
      body: JSON.stringify({ customer_id: c.id, email: c.email, code }),
    });
    enviados++;

    // Resend limita a pocas requests por segundo y acá se manda de a uno.
    await new Promise((r) => setTimeout(r, 600));
  }

  if (enviados > 0) {
    await sendNavidadReport({
      apiKey: resendKey,
      ownerEmail: OWNER_EMAIL,
      enviados,
      fallidos,
      yaTenian: yaTienen.size,
    });
  }

  return json({ ok: true, enviados, fallidos, yaTenian: yaTienen.size, modo: "real" }, 200);
});

async function traerConexion(supabaseUrl: string, svcHeaders: Record<string, string>) {
  const r = await fetch(
    `${supabaseUrl}/rest/v1/tiendanube_connection?select=store_id,access_token&limit=1`,
    { headers: svcHeaders },
  );
  return (await r.json())?.[0] ?? null;
}

// Un solo lugar donde se arma el cupón, para que la prueba cree exactamente
// el mismo que la corrida real. Si difirieran, la prueba no probaría nada.
async function crearCupon(
  conn: { store_id: string; access_token: string },
  code: string,
): Promise<{ ok: boolean; status: number; detalle: string }> {
  const res = await fetch(`https://api.tiendanube.com/v1/${conn.store_id}/coupons`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authentication: `bearer ${conn.access_token}`,
      "User-Agent": "Yokoo Club (jcdibastiano@gmail.com)",
    },
    body: JSON.stringify({
      code,
      type: "percentage",
      value: String(PORCENTAJE),
      valid: true,
      max_uses: 1,
      end_date: VENCE,
    }),
  });
  const detalle = res.ok ? "" : await res.text();
  if (!res.ok) console.error("Error creando cupón de Navidad:", code, res.status, detalle);
  return { ok: res.ok, status: res.status, detalle };
}

function sufijo(): string {
  const abc = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // sin I/O/0/1, que se confunden al tipear
  let s = "";
  for (let i = 0; i < 6; i++) s += abc[Math.floor(Math.random() * abc.length)];
  return s;
}

function maskEmail(email: string): string {
  const [u, d] = email.split("@");
  if (!d) return "***";
  return u.slice(0, 2) + "***@" + d;
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
}
