{# ---------------------------------------------------------------------------
   Captación para el Cyber del Club: barra fija + modal de registro.

   ESTADO: en vista previa. Sólo aparece si la URL lleva ?yk_gate=1
   Para publicarlo de verdad, cambiar VISIBLE_PARA_TODOS a true (abajo).

   Parámetros para probar:
     ?yk_gate=1            -> fase 1 (captación previa), barra abajo
     ?yk_gate=1&fase=2     -> fase 2 (Cyber abierto, 31/10)
     ?yk_gate=1&pos=arriba -> barra pegada arriba en vez de abajo
     ?yk_gate=1&modal=1    -> fuerza el modal aunque ya lo hayas cerrado

   Reglas de aparición, pensadas para no molestar:
     - La barra se muestra en toda la tienda. Se puede cerrar y no vuelve
       en 7 días.
     - El modal aparece UNA sola vez por visitante, a los 8 segundos, y
       NUNCA en una página de producto (ahí la persona ya está decidiendo
       una compra: interrumpirla es perder la venta).
     - Si alguien ya dejó su mail, no vuelve a ver ni la barra ni el modal.
--------------------------------------------------------------------------- #}

{% set VISIBLE_PARA_TODOS = false %}

<style>
  .yk-gate-bar {
    position: fixed; left: 0; right: 0; z-index: 9990;
    background: #C4331F; color: #FFF4E3;
    padding: 12px 16px;
    display: flex; align-items: center; justify-content: center;
    gap: 14px; flex-wrap: wrap;
    font-size: 14px; line-height: 1.35;
    box-shadow: 0 -4px 18px rgba(0,0,0,.18);
  }
  .yk-gate-bar[data-pos="abajo"] { bottom: 0; }
  .yk-gate-bar[data-pos="arriba"] { top: 0; box-shadow: 0 4px 18px rgba(0,0,0,.18); }
  .yk-gate-bar strong { font-weight: 800; }
  .yk-gate-bar .yk-sub { opacity: .82; font-size: 13px; }

  .yk-gate-form { display: flex; gap: 8px; flex-wrap: wrap; justify-content: center; }
  .yk-gate-form input[type="email"] {
    border: 0; border-radius: 999px; padding: 9px 16px;
    font-size: 14px; min-width: 230px; background: #FFFDF6; color: #3A2115;
  }
  .yk-gate-form input[type="email"]::placeholder { color: #9b8b79; }
  .yk-gate-form button {
    border: 0; border-radius: 999px; padding: 9px 20px; cursor: pointer;
    background: #F5EE93; color: #3A2115;
    font-size: 13px; font-weight: 800; text-transform: uppercase; letter-spacing: .03em;
  }
  .yk-gate-form button:hover { background: #fff8b8; }
  .yk-gate-close {
    background: transparent; border: 0; color: #FFF4E3; opacity: .6;
    font-size: 22px; line-height: 1; cursor: pointer; padding: 0 4px;
  }
  .yk-gate-close:hover { opacity: 1; }

  .yk-gate-overlay {
    position: fixed; inset: 0; z-index: 9995;
    background: rgba(36,27,20,.62);
    display: flex; align-items: center; justify-content: center; padding: 20px;
  }
  .yk-gate-modal {
    background: #F5EE93; border-radius: 22px; max-width: 420px; width: 100%;
    padding: 30px 26px 26px; text-align: center; position: relative;
    box-shadow: 0 20px 60px rgba(0,0,0,.3);
  }
  .yk-gate-modal .yk-gate-close { color: #3A2115; position: absolute; top: 12px; right: 16px; }
  .yk-gate-modal h3 {
    margin: 0 0 10px; color: #3A2115; font-size: 23px; font-weight: 800;
    line-height: 1.2; letter-spacing: -.02em;
  }
  .yk-gate-modal p { margin: 0 0 18px; color: #3A2115; opacity: .8; font-size: 14.5px; line-height: 1.5; }
  .yk-gate-modal .yk-gate-form { flex-direction: column; }
  .yk-gate-modal .yk-gate-form input[type="email"] { min-width: 0; width: 100%; background: #fffdf6; }
  .yk-gate-modal .yk-gate-form button { width: 100%; background: #3A2115; color: #F5EE93; }
  .yk-gate-modal .yk-gate-form button:hover { background: #4b2c1c; }
  .yk-gate-legal { margin: 12px 0 0; font-size: 11.5px; opacity: .6; color: #3A2115; }

  .yk-gate-entrar {
    display: inline-block; margin-left: 10px;
    background: #F5EE93; color: #3A2115; text-decoration: none;
    border-radius: 999px; padding: 9px 20px;
    font-size: 13px; font-weight: 800; text-transform: uppercase; letter-spacing: .03em;
  }
  .yk-gate-error {
    width: 100%; margin-top: 8px; text-align: center;
    font-size: 12.5px; color: #FFE0D6;
  }
  .yk-gate-modal .yk-gate-error { color: #8a2a18; }
  .yk-gate-ok { color: #FFF4E3; font-size: 14px; font-weight: 700; }
  .yk-gate-modal .yk-gate-ok { color: #3A2115; }

  @media (max-width: 575px) {
    .yk-gate-bar { font-size: 13px; padding: 10px 12px; gap: 10px; }
    .yk-gate-bar .yk-sub { display: none; }
    .yk-gate-form input[type="email"] { min-width: 0; flex: 1 1 150px; }
  }
</style>

<script>
(function () {
  "use strict";

  var VISIBLE_PARA_TODOS = {{ VISIBLE_PARA_TODOS ? 'true' : 'false' }};

  // La ventana (modal) queda apagada: Juan prefirió sólo la barra, que no
  // interrumpe. Poner en true para encenderla -- tiene sentido el 31, cuando
  // el Cyber ya está abierto y cada registro vale una venta.
  var MOSTRAR_MODAL = false;

  // Calendario. Hora de Argentina (UTC-3), expresado en UTC.
  //   26/10 00:00 ART -> fase 1: "sumate antes que nadie"
  //   31/10 00:00 ART -> fase 2: "el Cyber ya está abierto"
  //    4/11 23:59 ART -> se apaga solo, no hay que sacar nada
  var INICIO_FASE_1 = Date.parse("2026-10-26T03:00:00Z");
  var INICIO_FASE_2 = Date.parse("2026-10-31T03:00:00Z");
  var FIN           = Date.parse("2026-11-05T02:59:59Z");

  var q = new URLSearchParams(window.location.search);
  var preview = q.get("yk_gate") === "1";

  var ahora = Date.now();
  var FASE;
  if (preview) {
    FASE = q.get("fase") === "2" ? 2 : 1;
  } else {
    if (!VISIBLE_PARA_TODOS) return;
    if (ahora < INICIO_FASE_1 || ahora > FIN) return;
    FASE = ahora >= INICIO_FASE_2 ? 2 : 1;
  }

  var POS = q.get("pos") === "arriba" ? "arriba" : "abajo";
  var FORZAR_MODAL = q.get("modal") === "1";

  var TEXTOS = {
    1: {
      barra: "<strong>Sumate al Club de Yokoo antes que nadie.</strong> <span class='yk-sub'>Acceso anticipado al Cyber, el 31 de octubre.</span>",
      titulo: "Sumate al Club antes que nadie",
      bajada: "El 31 de octubre el Cyber abre primero para el Club, con el mejor descuento de los cinco días. Dejanos tu mail y entrás antes que todos.",
      boton: "Quiero entrar antes",
    },
    2: {
      barra: "<strong>El Cyber del Club ya está abierto.</strong> <span class='yk-sub'>Entrá con tu mail y accedé a los precios de socio.</span>",
      titulo: "El Cyber del Club ya está abierto",
      bajada: "Hoy las ofertas son sólo para el Club. Dejá tu mail y entrás al instante: no hace falta esperar ningún correo.",
      boton: "Entrar al Cyber",
    },
  }[FASE];

  // --- memoria del visitante (si falla, la página anda igual) --------------
  function leer(k) { try { return localStorage.getItem(k); } catch (e) { return null; } }
  function guardar(k, v) { try { localStorage.setItem(k, v); } catch (e) {} }

  var YA_DEJO_MAIL = leer("yk_gate_mail") === "1";
  var CERRO_BARRA = Number(leer("yk_gate_barra_cerrada") || 0) > Date.now() - 7 * 864e5;
  var YA_VIO_MODAL = leer("yk_gate_modal_visto") === "1";

  if (YA_DEJO_MAIL) return;

  // En la ficha de producto la persona ya está decidiendo una compra:
  // ahí el modal no aparece nunca.
  var esFichaDeProducto = !!document.querySelector(".js-product-detail, [data-store='product-detail'], .product-detail");

  function formulario(claseBoton) {
    return '<form class="yk-gate-form">' +
      '<input type="email" required placeholder="tu@mail.com" aria-label="Tu correo electrónico" />' +
      '<button type="submit">' + TEXTOS.boton + "</button>" +
      "</form>";
  }

  var ENDPOINT = "https://givnsohzgsugvrfuftcm.supabase.co/functions/v1/cyber-unlock";

  function conectar(form, contenedor) {
    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      var input = form.querySelector("input[type=email]");
      var boton = form.querySelector("button");
      var mail = input.value.trim();
      if (!mail) return;

      boton.disabled = true;
      var textoOriginal = boton.textContent;
      boton.textContent = "Un segundo...";

      fetch(ENDPOINT, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: mail }),
      })
        .then(function (r) { return r.json().then(function (d) { return { ok: r.ok, d: d }; }); })
        .then(function (res) {
          if (!res.ok || !res.d || !res.d.ok) {
            boton.disabled = false;
            boton.textContent = textoOriginal;
            mostrarError(form, (res.d && res.d.error) || "No pudimos registrarte. Probá de nuevo.");
            return;
          }
          guardar("yk_gate_mail", "1");
          if (FASE === 2 && res.d.url) {
            // El Cyber ya está abierto: se entra ahora, sin esperar el mail.
            contenedor.innerHTML =
              '<span class="yk-gate-ok">¡Listo, ya sos del Club!</span> ' +
              '<a class="yk-gate-entrar" href="' + res.d.url + '">Entrar al Cyber</a>';
          } else {
            contenedor.innerHTML =
              '<span class="yk-gate-ok">¡Listo! Te mandamos tu acceso por mail. ' +
              "Nos vemos el 31.</span>";
            setTimeout(function () {
              var ov = document.querySelector(".yk-gate-overlay");
              if (ov) ov.remove();
            }, 3200);
          }
        })
        .catch(function () {
          boton.disabled = false;
          boton.textContent = textoOriginal;
          mostrarError(form, "No pudimos conectarnos. Revisá tu conexión y probá de nuevo.");
        });
    });
  }

  function mostrarError(form, texto) {
    var prev = form.parentNode.querySelector(".yk-gate-error");
    if (prev) prev.remove();
    var e = document.createElement("div");
    e.className = "yk-gate-error";
    e.textContent = texto;
    form.parentNode.appendChild(e);
  }

  // --- barra ---------------------------------------------------------------
  if (!CERRO_BARRA) {
    var bar = document.createElement("div");
    bar.className = "yk-gate-bar";
    bar.setAttribute("data-pos", POS);
    bar.innerHTML = "<div>" + TEXTOS.barra + "</div>" + formulario() +
      '<button class="yk-gate-close" aria-label="Cerrar">&times;</button>';
    document.body.appendChild(bar);
    conectar(bar.querySelector("form"), bar);
    bar.querySelector(".yk-gate-close").addEventListener("click", function () {
      guardar("yk_gate_barra_cerrada", String(Date.now()));
      bar.remove();
    });
  }

  // --- modal ---------------------------------------------------------------
  function abrirModal() {
    if (document.querySelector(".yk-gate-overlay")) return;
    guardar("yk_gate_modal_visto", "1");
    var ov = document.createElement("div");
    ov.className = "yk-gate-overlay";
    ov.innerHTML =
      '<div class="yk-gate-modal" role="dialog" aria-modal="true">' +
        '<button class="yk-gate-close" aria-label="Cerrar">&times;</button>' +
        "<h3>" + TEXTOS.titulo + "</h3>" +
        "<p>" + TEXTOS.bajada + "</p>" +
        formulario() +
        '<p class="yk-gate-legal">Te registrás en Yokoo Club. Podés darte de baja cuando quieras.</p>' +
      "</div>";
    document.body.appendChild(ov);
    conectar(ov.querySelector("form"), ov.querySelector(".yk-gate-modal .yk-gate-form").parentNode);
    ov.querySelector(".yk-gate-close").addEventListener("click", function () { ov.remove(); });
    ov.addEventListener("click", function (e) { if (e.target === ov) ov.remove(); });
  }

  if (FORZAR_MODAL) setTimeout(abrirModal, 400);
  else if (MOSTRAR_MODAL && !YA_VIO_MODAL && !esFichaDeProducto) setTimeout(abrirModal, 8000);
})();
</script>
