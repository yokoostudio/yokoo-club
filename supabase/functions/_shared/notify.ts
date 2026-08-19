// Mail de aviso "sumaste una estrella", compartido entre las funciones que
// suman sellos (compra web, aprobación en el local, sello directo).

const FROM = "Yokoo Studio <club@mail.yokoo.com.ar>";

export async function sendStampEmail(opts: {
  toEmail: string;
  displayName: string | null;
  currentStamps: number;
  goal: number;
  appUrl: string;
}): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("RESEND_API_KEY no configurada -- no se manda el mail de aviso.");
    return false;
  }

  const name = opts.displayName || opts.toEmail.split("@")[0];
  const complete = opts.currentStamps >= opts.goal;

  const subject = complete
    ? "¡Completaste tu Credencial del Club! 🎁"
    : `¡Sumaste una estrella! ${opts.currentStamps}/${opts.goal} ⭐`;

  const bodyMessage = complete
    ? "¡Llegaste a las 5 estrellas! Entrá a tu credencial para descubrir y canjear tu premio sorpresa."
    : `Te faltan ${opts.goal - opts.currentStamps} estrella${opts.goal - opts.currentStamps === 1 ? "" : "s"} para destrabar tu premio.`;

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
