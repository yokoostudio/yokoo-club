{# ---------------------------------------------------------------------------
   Grilla de accesos del Cyber en el inicio: el bloque del 3x2 a todo el
   ancho y abajo las seis categorías de descuento.

   Va entre el banner y "MÁS ELEGIDOS", y sólo en el inicio.

   CALENDARIO (todo automático, nadie tiene que entrar al panel)
     2/11 00:00  aparece la grilla completa, con el bloque del 3x2 arriba
     3/11 00:00  se va el bloque del 3x2 y quedan las seis categorías
     5/11 00:00  se va todo

   El 3x2 dura un solo día -- así lo dice el mail del lunes ("sólo hoy,
   mañana cambia") -- así que el martes el bloque se saca solo. Si se
   quisiera dejar los tres días, alcanza con borrar HASTA_3X2.

   El 5 esto desaparece junto con el banner del Cyber, el renglón del menú
   y la barra de abajo. Igual, cuando vuelvan del viaje conviene borrar
   este archivo y sacar el include de layouts/layout.tpl, así no queda
   código dormido en el tema.

   PARA PROBARLO ANTES DE LA FECHA
     ?yk_grilla=1  -> como el lunes (con el bloque del 3x2)
     ?yk_grilla=2  -> como el martes y el miércoles (sin el 3x2)
     ?yk_grilla=0  -> apagado, aunque la fecha haya pasado
--------------------------------------------------------------------------- #}
<style>
  .yk-grilla {
    padding: 30px 0 10px;
  }
  .yk-grilla-caja {
    max-width: 1176px;
    margin: 0 auto;
    padding: 0 16px;
  }

  /* El bloque grande del 3x2. El banner de arriba ya es rojo, así que este
     va en el café de la marca para no armar dos manchas rojas pegadas. */
  .yk-grilla-3x2 {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 6px;
    min-height: 160px;
    padding: 26px 20px;
    margin-bottom: 14px;
    border-radius: 24px;
    background: #3a2115;
    color: #fff098;
    text-decoration: none;
    transition: transform .25s ease, box-shadow .25s ease;
  }
  .yk-grilla-3x2:hover {
    transform: translateY(-2px);
    box-shadow: 0 18px 36px -18px rgba(58, 33, 21, .55);
    color: #fff098;
  }
  .yk-grilla-3x2 b {
    font-size: 44px;
    font-weight: 800;
    line-height: 1;
    letter-spacing: -.02em;
  }
  .yk-grilla-3x2 span {
    font-size: 15px;
    font-weight: 400;
    opacity: .82;
  }

  /* El alto sale de una proporción y no de un número fijo, así se acomoda
     a cualquier ancho de pantalla sin quedar mal en un teléfono distinto.
     Cuadrados quedaban enormes, sobre todo en el celular: en computadora
     son apaisados (3:2) y en el celular más chatos todavía (2:1), donde
     entran de a dos y cada uno se lleva medio ancho de pantalla. */
  .yk-grilla-descuentos {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 14px;
  }
  .yk-grilla-descuentos a {
    display: flex;
    align-items: center;
    justify-content: center;
    aspect-ratio: 3 / 2;
    border-radius: 18px;
    background: #fff098;
    color: #3a2115;
    font-size: 26px;
    font-weight: 800;
    letter-spacing: -.01em;
    text-decoration: none;
    transition: background .2s ease, color .2s ease, transform .2s ease;
  }
  .yk-grilla-descuentos a:hover {
    background: #3a2115;
    color: #fff098;
    transform: translateY(-2px);
  }

  @media (max-width: 991px) {
    .yk-grilla-descuentos { grid-template-columns: repeat(3, 1fr); }
    .yk-grilla-descuentos a { aspect-ratio: 2 / 1; }
  }
  @media (max-width: 575px) {
    .yk-grilla { padding: 22px 0 6px; }
    .yk-grilla-descuentos { grid-template-columns: repeat(2, 1fr); gap: 10px; }
    .yk-grilla-descuentos a { font-size: 22px; border-radius: 14px; aspect-ratio: 2 / 1; }
    .yk-grilla-3x2 { min-height: 128px; padding: 22px 16px; border-radius: 18px; }
    .yk-grilla-3x2 b { font-size: 32px; }
    .yk-grilla-3x2 span { font-size: 13px; }
  }
</style>

<script>
(function () {
  "use strict";

  if (!document.body || !document.body.classList.contains("template-home")) return;

  // Horas de Argentina (UTC-3), escritas en UTC. El país no tiene horario
  // de verano, así que la cuenta es fija.
  var DESDE      = Date.parse("2026-11-02T03:00:00Z"); // lunes 2, 00:00
  var HASTA_3X2  = Date.parse("2026-11-03T03:00:00Z"); // martes 3, 00:00
  var HASTA      = Date.parse("2026-11-05T03:00:00Z"); // jueves 5, 00:00

  var DESCUENTOS = [
    ["10% OFF", "/cyber-10off"],
    ["15% OFF", "/cyber-15off"],
    ["20% OFF", "/cyber-20off"],
    ["25% OFF", "/cyber-25off"],
    ["30% OFF", "/cyber-30off"],
    ["40% OFF", "/cyber-40off"]
  ];

  // El 3x2 es sólo en remeras, así que lleva al listado de remeras y no al
  // del Cyber, que mezcla todo.
  var URL_3X2 = "/shop/remeras/";

  var forzado = new URLSearchParams(window.location.search).get("yk_grilla");
  var ahora = Date.now();

  var mostrar, con3x2;
  if (forzado === "0") {
    mostrar = false;
  } else if (forzado === "1" || forzado === "2") {
    mostrar = true;
    con3x2 = forzado === "1";
  } else {
    mostrar = ahora >= DESDE && ahora < HASTA;
    con3x2 = ahora < HASTA_3X2;
  }
  if (!mostrar) return;

  function armar() {
    if (document.querySelector(".yk-grilla")) return true;

    var contenedor = document.querySelector(".js-home-sections-container");
    var slider = contenedor && contenedor.querySelector(".js-home-slider-section");
    if (!contenedor || !slider) return false;

    var seccion = document.createElement("section");
    seccion.className = "yk-grilla";

    var caja = document.createElement("div");
    caja.className = "yk-grilla-caja";

    if (con3x2) {
      var destacado = document.createElement("a");
      destacado.className = "yk-grilla-3x2";
      destacado.setAttribute("href", URL_3X2);
      destacado.innerHTML =
        "<b>3X2 EN REMERAS</b><span>Llevás tres, pagás dos. Sólo hoy.</span>";
      caja.appendChild(destacado);
    }

    var fila = document.createElement("div");
    fila.className = "yk-grilla-descuentos";
    for (var i = 0; i < DESCUENTOS.length; i++) {
      var a = document.createElement("a");
      a.setAttribute("href", DESCUENTOS[i][1]);
      a.textContent = DESCUENTOS[i][0];
      fila.appendChild(a);
    }
    caja.appendChild(fila);

    seccion.appendChild(caja);
    slider.insertAdjacentElement("afterend", seccion);
    return true;
  }

  // El inicio lo dibuja el tema; si todavía no está el slider, se reintenta
  // un rato corto y después se deja de insistir.
  function intentar(vecesQueQuedan) {
    if (armar() || vecesQueQuedan <= 0) return;
    setTimeout(function () { intentar(vecesQueQuedan - 1); }, 250);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () { intentar(12); });
  } else {
    intentar(12);
  }
})();
</script>
