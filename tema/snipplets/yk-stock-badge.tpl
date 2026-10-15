{# ---------------------------------------------------------------------------
   Cartel de últimas unidades en las TARJETAS de producto (categorías, home,
   destacados). NO toca la ficha del producto, que ya tiene el aviso nativo
   de Tiendanube por talle.

   Reglas (15/10/2026, acordadas con Juan):
     1 unidad en total ............ ¡Último disponible!
     2 o 3 unidades en total ...... ¡Últimos 2! / ¡Últimos 3!
     un solo talle disponible ..... ¡Último talle!   (sólo si el producto
                                    tiene más de un talle: si no, las gorras
                                    y los productos de talle único lo
                                    mostrarían siempre)

   Por qué en JavaScript y no en la plantilla: el stock de cada talle ya viaja
   en el HTML de cada tarjeta (atributo data-variants, que sale de
   product.variants_object). Leerlo desde acá no le pide nada nuevo a
   Tiendanube, y sobre todo: si algo falla, el cartel no aparece y la tienda
   sigue funcionando igual. Un error en la plantilla de la tarjeta rompería
   todos los listados del sitio.

   Para desactivarlo: sacar el include de layouts/layout.tpl. Para cambiar el
   umbral: la constante MAX_UNIDADES de abajo.
--------------------------------------------------------------------------- #}

<style>
  .yk-stock-badge {
    display: block;
    width: fit-content;
    margin-bottom: 8px;
    padding: 4px 9px;
    border-radius: 6px;
    background: #3A2115;
    color: #F5EE93;
    font-size: 11px;
    font-weight: 700;
    line-height: 1.3;
    letter-spacing: .02em;
    text-transform: uppercase;
    white-space: nowrap;
    box-shadow: 0 2px 8px rgba(58, 33, 21, .35);
  }
  @media (max-width: 575px) {
    .yk-stock-badge { font-size: 10px; padding: 3px 7px; }
  }
</style>

<script>
(function () {
  "use strict";

  // Desde cuántas unidades en total se muestra el cartel. Subirlo hace que
  // aparezca más seguido (y antes).
  var MAX_UNIDADES = 3;

  function textoPara(datos) {
    // Sin control de stock: no sabemos cuánto hay, no inventamos urgencia.
    if (datos.sinControl) return null;
    // Sin stock: Tiendanube ya pone su propio cartel.
    if (datos.total <= 0) return null;

    if (datos.total === 1) return "¡Último disponible!";
    if (datos.total <= MAX_UNIDADES) return "¡Últimos " + datos.total + "!";
    // Queda un solo talle de varios: en ropa es lo que más urgencia genera,
    // y se activa mucho antes que el conteo de unidades.
    if (datos.talles > 1 && datos.tallesDisponibles === 1) return "¡Último talle!";
    return null;
  }

  function leerStock(card) {
    var cont = card.querySelector("[data-variants]");
    if (!cont) return null;
    var variantes;
    try {
      variantes = JSON.parse(cont.getAttribute("data-variants"));
    } catch (e) {
      return null;
    }
    if (!Array.isArray(variantes) || variantes.length === 0) return null;

    var total = 0, sinControl = false, tallesDisponibles = 0;
    for (var i = 0; i < variantes.length; i++) {
      var v = variantes[i];
      if (v.stock === null || typeof v.stock === "undefined") sinControl = true;
      else total += Number(v.stock) || 0;
      if (v.available) tallesDisponibles++;
    }
    return { total: total, sinControl: sinControl, talles: variantes.length, tallesDisponibles: tallesDisponibles };
  }

  function marcar(card) {
    if (card.querySelector(".yk-stock-badge")) return; // ya procesada
    var datos = leerStock(card);
    if (!datos) return;
    var texto = textoPara(datos);
    if (!texto) return;

    var grupo = card.querySelector(".js-labels-floating-group");
    if (!grupo) return;

    var el = document.createElement("span");
    el.className = "yk-stock-badge";
    el.textContent = texto;
    // Primero del grupo: la urgencia de stock se lee antes que el % OFF.
    grupo.insertBefore(el, grupo.firstChild);
  }

  function recorrer() {
    var cards = document.querySelectorAll(".js-item-product");
    for (var i = 0; i < cards.length; i++) marcar(cards[i]);
  }

  function arrancar() {
    recorrer();
    // Las categorías cargan más productos al filtrar o al scrollear, así que
    // hay que volver a pasar cuando aparecen tarjetas nuevas.
    if (!window.MutationObserver) return;
    var pendiente = null;
    new MutationObserver(function () {
      clearTimeout(pendiente);
      pendiente = setTimeout(recorrer, 120);
    }).observe(document.body, { childList: true, subtree: true });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", arrancar);
  } else {
    arrancar();
  }
})();
</script>
