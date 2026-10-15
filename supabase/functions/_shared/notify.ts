// Mail de aviso "sumaste una estrella", compartido entre las funciones que
// suman sellos (compra web, aprobación en el local, sello directo).

const FROM = "Yokoo Studio <club@mail.yokoo.com.ar>";

export async function sendStampEmail(opts: {
  toEmail: string;
  displayName: string | null;
  currentStamps: number;
  goal: number;
  appUrl: string;
  // Cuántas estrellas sumó ESTA compra. Normalmente 1; durante el Cyber son 2.
  // Opcional para no tocar las otras funciones que ya llamaban a esto.
  stampsAdded?: number;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda el mail de aviso.");
    return false;
  }

  const name = opts.displayName || opts.toEmail.split("@")[0];
  const complete = opts.currentStamps >= opts.goal;

  const doble = (opts.stampsAdded ?? 1) >= 2;
  const faltan = opts.goal - opts.currentStamps;

  const subject = complete
    ? "¡Completaste tu Credencial del Club! 🎁"
    : doble
      ? `¡Sumaste 2 estrellas! ${opts.currentStamps}/${opts.goal} ⭐⭐`
      : `¡Sumaste una estrella! ${opts.currentStamps}/${opts.goal} ⭐`;

  const bodyMessage = complete
    ? doble
      ? "¡Llegaste a las 5 estrellas con el doble del Cyber! Entrá a tu credencial para descubrir y canjear tu premio sorpresa."
      : "¡Llegaste a las 5 estrellas! Entrá a tu credencial para descubrir y canjear tu premio sorpresa."
    : doble
      ? `Compraste en el Cyber, así que esta compra valió doble. Te faltan ${faltan} estrella${faltan === 1 ? "" : "s"} para destrabar tu premio.`
      : `Te faltan ${faltan} estrella${faltan === 1 ? "" : "s"} para destrabar tu premio.`;

  const html = renderEmailHtml({ name, currentStamps: opts.currentStamps, goal: opts.goal, bodyMessage, appUrl: opts.appUrl });

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM,
        to: [opts.toEmail],
        subject,
        html,
      }),
    });

    if (!res.ok) {
      console.error("Error enviando mail de aviso:", res.status, await res.text());
      return false;
    }
    return true;
  } catch (e) {
    console.error("Excepción enviando mail de aviso:", e);
    return false;
  }
}

// Le manda al dueño del negocio los datos que tenemos guardados de un
// cliente, cuando ese cliente pidió una copia (webhook "customers/data_request"
// de Tiendanube). El dueño se lo reenvía al cliente por su canal habitual --
// no tenemos un flujo de autoservicio para esto todavía.
export async function sendDataRequestReport(opts: {
  ownerEmail: string;
  customerEmail: string;
  reportText: string;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda el reporte de datos.");
    return false;
  }

  const html = `<pre style="font-family:ui-monospace,monospace;white-space:pre-wrap;font-size:13px;">${escapeHtml(opts.reportText)}</pre>`;

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM,
        to: [opts.ownerEmail],
        subject: `Pedido de datos -- ${opts.customerEmail}`,
        html,
      }),
    });
    if (!res.ok) {
      console.error("Error enviando reporte de datos:", res.status, await res.text());
      return false;
    }
    return true;
  } catch (e) {
    console.error("Excepción enviando reporte de datos:", e);
    return false;
  }
}

// Invita a sumarse al club a alguien que compró en la web sin estar
// registrado todavía. El link ya lo deja logueado directo (magic link
// generado por nosotros), no tiene que volver a escribir el mail.
export async function sendInviteEmail(opts: {
  toEmail: string;
  displayName: string | null;
  magicLink: string;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda la invitación.");
    return false;
  }

  const name = opts.displayName || opts.toEmail.split("@")[0];
  const html = renderInviteHtml({ name, magicLink: opts.magicLink });

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM,
        to: [opts.toEmail],
        subject: "¡Gracias por tu compra! Sumate al Club Yokoo ⭐",
        html,
      }),
    });
    if (!res.ok) {
      console.error("Error enviando invitación:", res.status, await res.text());
      return false;
    }
    return true;
  } catch (e) {
    console.error("Excepción enviando invitación:", e);
    return false;
  }
}

// Mail de bienvenida con un cupón de descuento exclusivo, para quien se
// registra por primera vez en la app sin haber comprado todavía (ver
// tn-welcome-coupon).
export async function sendWelcomeCouponEmail(opts: {
  toEmail: string;
  displayName: string | null;
  code: string;
  percent: string;
  appUrl: string;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda el mail de bienvenida.");
    return false;
  }

  const name = opts.displayName || opts.toEmail.split("@")[0];
  const html = renderWelcomeCouponHtml({ name, code: opts.code, percent: opts.percent, appUrl: opts.appUrl });

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM,
        to: [opts.toEmail],
        subject: `Tu ${opts.percent}% de descuento de bienvenida a Yokoo Members 🎁`,
        html,
      }),
    });
    if (!res.ok) {
      console.error("Error enviando mail de bienvenida:", res.status, await res.text());
      return false;
    }
    return true;
  } catch (e) {
    console.error("Excepción enviando mail de bienvenida:", e);
    return false;
  }
}

function renderWelcomeCouponHtml(opts: { name: string; code: string; percent: string; appUrl: string }): string {
  return `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="text-align:center; padding-bottom:18px;">
      <img src="https://givnsohzgsugvrfuftcm.supabase.co/storage/v1/object/public/assets/logo-yokoo-studio.png" width="190" alt="Yokoo Studio" style="display:block; margin:0 auto; width:190px; height:auto; max-width:100%;" />
    </td></tr>
    <tr><td style="background:#3a2115; border-radius:20px; padding:28px 24px; text-align:center;">
      <p style="margin:0 0 6px; color:#f6efa3; font-size:14px;">Hola ${escapeHtml(opts.name)},</p>
      <p style="margin:0 0 18px; color:#f6efa3; font-size:20px; font-weight:800; line-height:1.35;">¡Bienvenido/a a Yokoo Members!</p>
      <p style="margin:0 0 22px; color:rgba(246,239,163,.85); font-size:14px; line-height:1.5;">Como regalo de bienvenida, tenés un ${opts.percent}% de descuento exclusivo para tu primera compra.</p>
      <p style="margin:0 0 8px; color:rgba(246,239,163,.6); font-size:11px; text-transform:uppercase; letter-spacing:.08em;">Tu código</p>
      <p style="margin:0 0 22px; color:#f6efa3; font-size:26px; font-weight:800; letter-spacing:2px;">${escapeHtml(opts.code)}</p>
      <a href="${opts.appUrl}" style="display:inline-block; background:#f6efa3; color:#3a2115; text-decoration:none; font-weight:800; font-size:13px; text-transform:uppercase; letter-spacing:.04em; padding:12px 22px; border-radius:999px;">Ver mi credencial</a>
      <p style="margin:18px 0 0; color:rgba(246,239,163,.55); font-size:11px;">Además, cada compra suma una estrella para tu premio sorpresa.</p>
    </td></tr>
  </table>
</body>
</html>`;
}

// Invitación a dejar una reseña, ~14 días después de la compra (ver
// review-invites). El link ya lleva el token único de esa compra, así que
// no hace falta que la persona se loguee ni escriba nada para entrar.
export async function sendReviewInviteEmail(opts: {
  toEmail: string;
  displayName: string | null;
  reviewUrl: string;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda la invitación a reseñar.");
    return false;
  }

  const name = opts.displayName || opts.toEmail.split("@")[0];
  const html = renderReviewInviteHtml({ name, reviewUrl: opts.reviewUrl });

  return await sendViaResend(apiKey, opts.toEmail, "¿Cómo fue tu experiencia con Yokoo?", html, "invitación a reseñar");
}

// Agradecimiento + cupón (y la estrella, si corresponde) apenas la persona
// envía su reseña (ver review-submit).
export async function sendReviewThanksEmail(opts: {
  toEmail: string;
  displayName: string | null;
  code: string;
  percent: string;
  starAwarded: boolean;
  appUrl: string;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda el agradecimiento.");
    return false;
  }

  const name = opts.displayName || opts.toEmail.split("@")[0];
  const html = renderReviewThanksHtml({
    name,
    code: opts.code,
    percent: opts.percent,
    starAwarded: opts.starAwarded,
    appUrl: opts.appUrl,
  });

  return await sendViaResend(apiKey, opts.toEmail, `¡Gracias por tu opinión! Acá va tu ${opts.percent}% de descuento`, html, "agradecimiento de reseña");
}

// Aviso interno para el dueño: se manda después de cada tanda de
// invitaciones a reseñar, para que sepa que salieron sin tener que entrar a
// mirar. Sólo se manda cuando efectivamente salió al menos una.
export async function sendReviewRunReport(opts: {
  ownerEmail: string;
  invited: number;
  pending: number;
  appUrl: string;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda el aviso de la tanda.");
    return false;
  }

  const plural = opts.invited === 1 ? "invitación" : "invitaciones";
  const pendientes = opts.pending === 1
    ? "Tenés <strong style=\"color:#f6efa3;\">1 reseña</strong> esperando que la publiques."
    : opts.pending > 1
      ? `Tenés <strong style="color:#f6efa3;">${opts.pending} reseñas</strong> esperando que las publiques.`
      : "Por ahora no hay reseñas esperando aprobación.";

  const html = `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="background:#3a2115; border-radius:20px; padding:26px 24px; text-align:center;">
      <p style="margin:0 0 6px; color:rgba(246,239,163,.6); font-size:11px; text-transform:uppercase; letter-spacing:.09em;">Yokoo · aviso interno</p>
      <p style="margin:0 0 16px; color:#f6efa3; font-size:20px; font-weight:800;">Se enviaron ${opts.invited} ${plural} a reseñar</p>
      <p style="margin:0 0 22px; color:rgba(246,239,163,.85); font-size:14px; line-height:1.5;">${pendientes}</p>
      <a href="${opts.appUrl}" style="display:inline-block; background:#f6efa3; color:#3a2115; text-decoration:none; font-weight:800; font-size:13px; text-transform:uppercase; letter-spacing:.04em; padding:12px 22px; border-radius:999px;">Ir al panel</a>
    </td></tr>
  </table>
</body>
</html>`;

  return await sendViaResend(apiKey, opts.ownerEmail, `Se enviaron ${opts.invited} ${plural} a reseñar`, html, "aviso de tanda de reseñas");
}

async function sendViaResend(apiKey: string, to: string, subject: string, html: string, label: string): Promise<boolean> {
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ from: FROM, to: [to], subject, html }),
    });
    if (!res.ok) {
      console.error(`Error enviando ${label}:`, res.status, await res.text());
      return false;
    }
    return true;
  } catch (e) {
    console.error(`Excepción enviando ${label}:`, e);
    return false;
  }
}

function renderReviewInviteHtml(opts: { name: string; reviewUrl: string }): string {
  return `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="text-align:center; padding-bottom:18px;">
      <img src="https://givnsohzgsugvrfuftcm.supabase.co/storage/v1/object/public/assets/logo-yokoo-studio.png" width="190" alt="Yokoo Studio" style="display:block; margin:0 auto; width:190px; height:auto; max-width:100%;" />
    </td></tr>
    <tr><td style="background:#3a2115; border-radius:20px; padding:28px 24px; text-align:center;">
      <p style="margin:0 0 6px; color:#f6efa3; font-size:14px;">Hola ${escapeHtml(opts.name)},</p>
      <p style="margin:0 0 16px; color:#f6efa3; font-size:20px; font-weight:800; line-height:1.35;">¿Cómo fue tu experiencia con Yokoo?</p>
      <p style="margin:0 0 22px; color:rgba(246,239,163,.85); font-size:14px; line-height:1.5;">Contanos qué te pareció: nos ayuda un montón y ayuda a quien todavía no nos conoce. Te lleva menos de un minuto.</p>
      <p style="margin:0 0 22px; font-size:26px; letter-spacing:4px; color:#f6efa3;">★★★★★</p>
      <a href="${opts.reviewUrl}" style="display:inline-block; background:#f6efa3; color:#3a2115; text-decoration:none; font-weight:800; font-size:13px; text-transform:uppercase; letter-spacing:.04em; padding:12px 22px; border-radius:999px;">Dejar mi opinión</a>
      <p style="margin:20px 0 0; color:rgba(246,239,163,.7); font-size:12.5px; line-height:1.5;">Al enviarla te regalamos un <strong style="color:#f6efa3;">10% de descuento</strong> para tu próxima compra. Y si sos parte de Yokoo Members, sumás además una estrella ⭐</p>
    </td></tr>
  </table>
</body>
</html>`;
}

function renderReviewThanksHtml(opts: { name: string; code: string; percent: string; starAwarded: boolean; appUrl: string }): string {
  const starBlock = opts.starAwarded
    ? `<p style="margin:18px 0 0; color:rgba(246,239,163,.75); font-size:12.5px;">Además sumaste <strong style="color:#f6efa3;">una estrella ⭐</strong> en tu tarjeta Yokoo Members.</p>`
    : `<p style="margin:18px 0 0; color:rgba(246,239,163,.75); font-size:12.5px;">Sumate a Yokoo Members y empezá a juntar estrellas en cada compra.</p>`;

  return `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="text-align:center; padding-bottom:18px;">
      <img src="https://givnsohzgsugvrfuftcm.supabase.co/storage/v1/object/public/assets/logo-yokoo-studio.png" width="190" alt="Yokoo Studio" style="display:block; margin:0 auto; width:190px; height:auto; max-width:100%;" />
    </td></tr>
    <tr><td style="background:#3a2115; border-radius:20px; padding:28px 24px; text-align:center;">
      <p style="margin:0 0 6px; color:#f6efa3; font-size:14px;">Hola ${escapeHtml(opts.name)},</p>
      <p style="margin:0 0 18px; color:#f6efa3; font-size:20px; font-weight:800; line-height:1.35;">¡Gracias por tu opinión!</p>
      <p style="margin:0 0 22px; color:rgba(246,239,163,.85); font-size:14px; line-height:1.5;">Acá va tu ${opts.percent}% de descuento para tu próxima compra.</p>
      <p style="margin:0 0 8px; color:rgba(246,239,163,.6); font-size:11px; text-transform:uppercase; letter-spacing:.08em;">Tu código</p>
      <p style="margin:0 0 22px; color:#f6efa3; font-size:26px; font-weight:800; letter-spacing:2px;">${escapeHtml(opts.code)}</p>
      <a href="${opts.appUrl}" style="display:inline-block; background:#f6efa3; color:#3a2115; text-decoration:none; font-weight:800; font-size:13px; text-transform:uppercase; letter-spacing:.04em; padding:12px 22px; border-radius:999px;">Ver mi credencial</a>
      ${starBlock}
    </td></tr>
  </table>
</body>
</html>`;
}

function renderInviteHtml(opts: { name: string; magicLink: string }): string {
  return `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="text-align:center; padding-bottom:18px;">
      <img src="https://givnsohzgsugvrfuftcm.supabase.co/storage/v1/object/public/assets/logo-yokoo-studio.png" width="190" alt="Yokoo Studio" style="display:block; margin:0 auto; width:190px; height:auto; max-width:100%;" />
    </td></tr>
    <tr><td style="background:#3a2115; border-radius:20px; padding:28px 24px; text-align:center;">
      <p style="margin:0 0 6px; color:#f6efa3; font-size:14px;">Hola ${escapeHtml(opts.name)},</p>
      <p style="margin:0 0 4px; color:#f6efa3; font-size:19px; font-weight:800; line-height:1.35;">¡Gracias por tu compra!</p>
      <p style="margin:0 0 22px; color:rgba(246,239,163,.85); font-size:19px; font-weight:400; line-height:1.5;">Sumate al Club y empezá a coleccionar estrellas por cada compra.</p>
      <p style="margin:0 0 22px; color:rgba(246,239,163,.7); font-size:13px;">Ya te guardamos esta compra -- tocá el botón para crear tu credencial y sumarla.</p>
      <a href="${opts.magicLink}" style="display:inline-block; background:#f6efa3; color:#3a2115; text-decoration:none; font-weight:800; font-size:13px; text-transform:uppercase; letter-spacing:.04em; padding:12px 22px; border-radius:999px;">Sumarme al club</a>
    </td></tr>
  </table>
</body>
</html>`;
}

function escapeHtml(s: string): string {
  return s.replace(/[&<>"']/g, (c) => (
    { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string
  ));
}

function renderEmailHtml(opts: {
  name: string;
  currentStamps: number;
  goal: number;
  bodyMessage: string;
  appUrl: string;
}): string {
  var stars = "";
  for (var i = 1; i <= opts.goal; i++) {
    stars += i <= opts.currentStamps ? "★" : "☆";
  }

  return `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="text-align:center; padding-bottom:18px;">
      <span style="font-weight:800; font-size:22px; color:#3a2115; letter-spacing:-0.01em;">yokoo studio</span>
    </td></tr>
    <tr><td style="background:#3a2115; border-radius:20px; padding:28px 24px; text-align:center;">
      <p style="margin:0 0 6px; color:#f6efa3; font-size:14px;">Hola ${escapeHtml(opts.name)},</p>
      <p style="margin:0 0 18px; color:#f6efa3; font-size:20px; font-weight:700;">${escapeHtml(opts.bodyMessage)}</p>
      <p style="margin:0 0 18px; font-size:28px; letter-spacing:4px; color:#f6efa3;">${stars}</p>
      <p style="margin:0 0 20px; color:rgba(246,239,163,.7); font-size:13px;">${opts.currentStamps} / ${opts.goal} estrellas</p>
      <a href="${opts.appUrl}" style="display:inline-block; background:#f6efa3; color:#3a2115; text-decoration:none; font-weight:800; font-size:13px; text-transform:uppercase; letter-spacing:.04em; padding:12px 22px; border-radius:999px;">Ver mi credencial</a>
    </td></tr>
  </table>
</body>
</html>`;
}

// ---------------------------------------------------------------------------
// Campañas a toda la lista del Club (lanzamientos, CyberMonday, etc.)
//
// A diferencia del resto de este archivo, acá el CONTENIDO no está en el
// código: llega como parámetro desde campaign-send. La plantilla de marca sí
// vive acá, así todas las campañas salen con la misma cara.
// ---------------------------------------------------------------------------

export type CampaignContent = {
  headline: string;
  paragraphs: string[];
  // Varias fotos: con una queda a lo ancho; con dos o más se arma una grilla de
  // a dos por fila. Si el total es impar, la primera va grande arriba y el
  // resto de a pares, que es como se ve una colección de ropa.
  images?: string[];
  // Compatibilidad: una sola foto. Si vienen las dos, mandan `images`.
  imageUrl?: string;
  imageAlt?: string;
  ctaText?: string;
  ctaUrl?: string;
  footnote?: string;
};

export type CampaignRecipient = {
  email: string;
  name: string;
  unsubUrl: string;
};

// Resend acepta hasta 100 mails por llamada a /emails/batch. Mandar de a uno
// no sirve acá: el rate limit de la API es de pocas requests por segundo y
// 170 mails sueltos se pasarían del tiempo máximo de la función.
const BATCH_SIZE = 100;

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

// Las fotos van en una tabla anidada, no en CSS grid ni flex: Outlook de
// escritorio no soporta ninguno de los dos y rompe el layout. Mismo motivo por
// el que el ancho va también en el atributo width= y no sólo en el style.
function renderImages(urls: string[], alt: string): string {
  const pics = urls.filter((u) => u && String(u).trim());
  if (pics.length === 0) return "";

  const safeAlt = escapeHtml(alt);
  const img = (src: string, w: number) =>
    `<img src="${src}" alt="${safeAlt}" width="${w}" style="display:block; width:100%; max-width:${w}px; height:auto; border-radius:14px;" />`;

  const rows: string[] = [];
  let i = 0;

  // Cantidad impar: la primera va grande arriba y el resto de a pares, así no
  // queda nunca una foto sola y desbalanceada al final.
  if (pics.length % 2 === 1) {
    rows.push(`<tr><td colspan="2" style="padding:0 0 10px;">${img(pics[0], 420)}</td></tr>`);
    i = 1;
  }

  for (; i < pics.length; i += 2) {
    rows.push(
      `<tr>` +
        `<td width="50%" style="padding:0 5px 10px 0;">${img(pics[i], 205)}</td>` +
        `<td width="50%" style="padding:0 0 10px 5px;">${img(pics[i + 1], 205)}</td>` +
      `</tr>`,
    );
  }

  return `<tr><td style="padding-bottom:8px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">${rows.join("")}</table>
    </td></tr>`;
}

export function renderCampaignHtml(opts: CampaignContent & { name: string; unsubUrl: string }): string {
  const paragraphs = opts.paragraphs
    .map(
      (p) =>
        `<p style="margin:0 0 14px; color:rgba(246,239,163,.88); font-size:15px; line-height:1.55;">${escapeHtml(p)}</p>`,
    )
    .join("");

  const image = renderImages(
    opts.images && opts.images.length ? opts.images : opts.imageUrl ? [opts.imageUrl] : [],
    opts.imageAlt || "",
  );

  const cta =
    opts.ctaText && opts.ctaUrl
      ? `<a href="${opts.ctaUrl}" style="display:inline-block; margin-top:8px; background:#f6efa3; color:#3a2115; text-decoration:none; font-weight:800; font-size:13px; text-transform:uppercase; letter-spacing:.04em; padding:13px 24px; border-radius:999px;">${escapeHtml(opts.ctaText)}</a>`
      : "";

  const footnote = opts.footnote
    ? `<p style="margin:16px 0 0; color:rgba(246,239,163,.6); font-size:12.5px; line-height:1.5;">${escapeHtml(opts.footnote)}</p>`
    : "";

  return `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="text-align:center; padding-bottom:18px;">
      <img src="https://givnsohzgsugvrfuftcm.supabase.co/storage/v1/object/public/assets/logo-yokoo-studio.png" width="190" alt="Yokoo Studio" style="display:block; margin:0 auto; width:190px; height:auto; max-width:100%;" />
    </td></tr>
    ${image}
    <tr><td style="background:#3a2115; border-radius:20px; padding:28px 24px; text-align:center;">
      ${opts.name ? `<p style="margin:0 0 6px; color:rgba(246,239,163,.75); font-size:14px;">Hola ${escapeHtml(opts.name)},</p>` : ""}
      <p style="margin:0 0 16px; color:#f6efa3; font-size:21px; font-weight:800; line-height:1.3;">${escapeHtml(opts.headline)}</p>
      ${paragraphs}
      ${cta}
      ${footnote}
    </td></tr>
    <tr><td style="padding:18px 8px 0; text-align:center;">
      <p style="margin:0; color:rgba(58,33,21,.6); font-size:11.5px; line-height:1.5;">
        Recibís esto porque estás registrado/a en Yokoo Club.<br />
        <a href="${opts.unsubUrl}" style="color:rgba(58,33,21,.75);">No quiero recibir más novedades</a>
      </p>
    </td></tr>
  </table>
</body>
</html>`;
}

// Versión en texto plano del mail. Va junto con el HTML (no en lugar de).
// Un mail que es sólo HTML puntúa peor en los filtros de spam y de pestañas:
// mandar las dos versiones es de las pocas cosas que dependen de nosotros.
function renderCampaignText(opts: CampaignContent & { name: string; unsubUrl: string }): string {
  const lineas: string[] = [];
  if (opts.name) lineas.push(`Hola ${opts.name},`, "");
  lineas.push(opts.headline, "");
  for (const p of opts.paragraphs) lineas.push(p, "");
  if (opts.ctaText && opts.ctaUrl) lineas.push(`${opts.ctaText}: ${opts.ctaUrl}`, "");
  if (opts.footnote) lineas.push(opts.footnote, "");
  lineas.push(
    "--",
    "Recibís esto porque estás registrado/a en Yokoo Club.",
    `Para no recibir más novedades: ${opts.unsubUrl}`,
  );
  return lineas.join("\n");
}

// Manda la campaña en tandas de 100. Devuelve qué mails salieron y cuáles no,
// para que campaign-send registre en campaign_sends SÓLO los que salieron: si
// una tanda falla, volver a correr la campaña reintenta nada más que esos.
export async function sendCampaignBatch(
  apiKey: string,
  subject: string,
  content: CampaignContent,
  recipients: CampaignRecipient[],
): Promise<{ sent: string[]; failed: string[] }> {
  const sent: string[] = [];
  const failed: string[] = [];

  for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
    const chunk = recipients.slice(i, i + BATCH_SIZE);
    const payload = chunk.map((r) => ({
      from: FROM,
      to: [r.email],
      subject,
      html: renderCampaignHtml({ ...content, name: r.name, unsubUrl: r.unsubUrl }),
      text: renderCampaignText({ ...content, name: r.name, unsubUrl: r.unsubUrl }),
      headers: {
        // Gmail y Outlook exigen las dos para mensajes masivos. La segunda
        // hace que el botón "Cancelar suscripción" del cliente de mail pegue
        // un POST a la misma URL, sin que la persona tenga que abrir nada.
        "List-Unsubscribe": `<${r.unsubUrl}>`,
        "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
      },
    }));

    // Resend limita a pocas requests por segundo: entre tanda y tanda hay que
    // esperar. Sin esto, la segunda tanda puede volver con 429 y perderse 100
    // mails de una (ya pasó en una prueba).
    if (i > 0) await sleep(1000);

    let ok = false;
    for (let intento = 1; intento <= 2 && !ok; intento++) {
      try {
        const res = await fetch("https://api.resend.com/emails/batch", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(payload),
        });
        if (res.ok) {
          ok = true;
        } else {
          const detalle = await res.text();
          console.error(`Error en tanda de campaña (intento ${intento}):`, res.status, detalle);
          // 429 = rate limit, 5xx = problema pasajero de Resend: vale reintentar.
          // Un 4xx que no sea 429 es un payload mal armado y reintentarlo no arregla nada.
          if (intento === 1 && (res.status === 429 || res.status >= 500)) await sleep(3000);
          else break;
        }
      } catch (e) {
        console.error(`Excepción en tanda de campaña (intento ${intento}):`, e);
        if (intento === 1) await sleep(3000);
      }
    }

    for (const r of chunk) (ok ? sent : failed).push(r.email);
  }

  return { sent, failed };
}

// Aviso interno al dueño cuando termina una campaña, mismo criterio que
// sendReviewRunReport: saber que salió sin tener que abrir el panel.
export async function sendCampaignReport(opts: {
  apiKey: string;
  ownerEmail: string;
  slug: string;
  subject: string;
  sent: number;
  failed: number;
  skipped: number;
}): Promise<boolean> {
  const html = `<!doctype html>
<html lang="es">
<head><meta charset="utf-8" /></head>
<body style="margin:0; padding:24px; background:#f5ee93; font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" style="max-width:420px; margin:0 auto;">
    <tr><td style="background:#3a2115; border-radius:20px; padding:26px 24px;">
      <p style="margin:0 0 14px; color:#f6efa3; font-size:19px; font-weight:800;">Campaña enviada</p>
      <p style="margin:0 0 6px; color:rgba(246,239,163,.85); font-size:14px;">Campaña: <b>${escapeHtml(opts.slug)}</b></p>
      <p style="margin:0 0 6px; color:rgba(246,239,163,.85); font-size:14px;">Asunto: ${escapeHtml(opts.subject)}</p>
      <p style="margin:14px 0 0; color:#f6efa3; font-size:15px;">✅ ${opts.sent} enviados</p>
      ${opts.failed ? `<p style="margin:6px 0 0; color:#ffb4a2; font-size:15px;">⚠️ ${opts.failed} fallaron — volvé a correr la campaña, sólo reintenta esos</p>` : ""}
      ${opts.skipped ? `<p style="margin:6px 0 0; color:rgba(246,239,163,.6); font-size:13px;">${opts.skipped} salteados (ya la habían recibido o están dados de baja)</p>` : ""}
    </td></tr>
  </table>
</body>
</html>`;

  return await sendViaResend(opts.apiKey, opts.ownerEmail, `Campaña "${opts.slug}": ${opts.sent} enviados`, html, "reporte de campaña");
}
