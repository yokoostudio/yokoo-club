{# ---------------------------------------------------------------------------
   "Sumá a tu compra" dentro del carrito.

   POR QUÉ
   El tema traía los sugeridos en una ventana aparte que se abría al agregar
   al carrito, encima del aviso que ya mostraba el producto agregado: dos
   ventanas para la misma acción. Y la del medio salía rota (el tema la
   llenaba y después le pisaba el contenido con el HTML de los relacionados,
   dejando la foto y el nombre en blanco). Esa ventana se apagó desde el
   panel; los sugeridos se mudan acá, al carrito, que es donde la persona
   ya está mirando lo que va a comprar.

   CÓMO ELIGE LOS PRODUCTOS
   No hay un listado de productos disponible dentro del carrito, así que se
   arma con lo que ya está en la página (las tarjetas de producto). Si la
   persona está en una página sin tarjetas -- una ficha de producto, el
   carrito -- se busca una sola vez el listado de la tienda y se guarda en
   la sesión, para no pedirlo de nuevo en cada apertura.

   Se barajan en cada apertura, así no muestra siempre los mismos, y se
   sacan los que ya están en el carrito: sugerir algo que la persona ya
   puso adentro es ruido.

   Va ENTRE los productos y los totales, a propósito: debajo de los totales
   empujaría el botón de pagar fuera de la pantalla.
--------------------------------------------------------------------------- #}
<style>
  .yk-reco { border-top: 1px solid rgba(0,0,0,.08); margin-top: 18px; padding-top: 16px; }
  .yk-reco-titulo { font-size: 13px; font-weight: 700; letter-spacing: .04em; text-transform: uppercase; margin: 0 0 12px; opacity: .75; }
  .yk-reco-fila { display: flex; gap: 10px; overflow-x: auto; scrollbar-width: thin; padding-bottom: 6px; -webkit-overflow-scrolling: touch; }
  /* El color va forzado en los cuatro estados. El tema le da otro color a
     los enlaces ya visitados, y sobre el fondo oscuro del carrito eso dejaba
     el nombre y el precio en gris oscuro, casi ilegibles -- justo en los
     productos que la persona YA miró, que son los más probables de comprar. */
  .yk-reco .yk-reco-item,
  .yk-reco .yk-reco-item:link,
  .yk-reco .yk-reco-item:visited,
  .yk-reco .yk-reco-item:hover,
  .yk-reco .yk-reco-item:focus { flex: 0 0 104px; text-decoration: none; color: currentColor; display: block; }
  .yk-reco .yk-reco-item * { color: inherit; }
  .yk-reco-item img { width: 104px; height: 130px; object-fit: cover; border-radius: 8px; display: block; background: rgba(0,0,0,.04); }
  .yk-reco-nombre { font-size: 11px; line-height: 1.3; margin: 6px 0 2px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .yk-reco-precio { font-size: 12px; font-weight: 700; }
</style>
<script>
(function () {
  "use strict";

  var CUANTOS = 6;
  var LISTADO = "/productos/";
  var CLAVE_CACHE = "ykReco";

  function texto(el, sel) {
    var e = el.querySelector(sel);
    return e ? (e.textContent || "").trim() : "";
  }

  // De una tarjeta de producto a los cuatro datos que necesitamos.
  function leerTarjeta(card) {
    var link = card.querySelector('a.item-link, a[href*="/productos/"]');
    var img = card.querySelector("img[srcset], img[data-srcset]");
    var src = img ? (img.getAttribute("srcset") || img.getAttribute("data-srcset") || "") : "";
    var nombre = texto(card, ".js-item-name");
    var precio = texto(card, ".js-price-display");
    if (!link || !nombre) return null;
    return {
      url: link.getAttribute("href"),
      nombre: nombre,
      precio: precio,
      img: src.split(" ")[0]
    };
  }

  // Sin repetidos: la misma página lista un producto en varias secciones
  // (destacados, relacionados, vistos), y sin esto el carrito terminaba
  // sugiriendo dos veces la misma remera.
  function desdeDocumento(doc) {
    var out = [];
    var vistos = {};
    var cards = doc.querySelectorAll(".js-item-product");
    for (var i = 0; i < cards.length; i++) {
      var p = leerTarjeta(cards[i]);
      if (!p || !p.img) continue;
      var m = (p.url || "").match(/\/productos\/([^/?#]+)/);
      var id = m ? m[1] : p.url;
      if (vistos[id]) continue;
      vistos[id] = true;
      out.push(p);
    }
    return out;
  }

  function guardar(lista) {
    try { sessionStorage.setItem(CLAVE_CACHE, JSON.stringify(lista)); } catch (e) {}
  }

  function leerCache() {
    try {
      var v = sessionStorage.getItem(CLAVE_CACHE);
      return v ? JSON.parse(v) : null;
    } catch (e) { return null; }
  }

  // Devuelve la lista de candidatos. Primero lo que hay en la página, que no
  // cuesta nada; si no alcanza, el listado de la tienda, una sola vez.
  function candidatos() {
    var enPagina = desdeDocumento(document);
    if (enPagina.length >= CUANTOS) {
      guardar(enPagina);
      return Promise.resolve(enPagina);
    }
    var guardados = leerCache();
    if (guardados && guardados.length) return Promise.resolve(guardados);

    return fetch(LISTADO, { credentials: "same-origin" })
      .then(function (r) { return r.ok ? r.text() : ""; })
      .then(function (html) {
        if (!html) return enPagina;
        var doc = new DOMParser().parseFromString(html, "text/html");
        var lista = desdeDocumento(doc);
        if (lista.length) guardar(lista);
        return lista.length ? lista : enPagina;
      })
      .catch(function () { return enPagina; });
  }

  // Qué hay ya en el carrito, para no sugerirlo.
  function yaEnElCarrito() {
    var urls = {};
    var items = document.querySelectorAll('.js-ajax-cart-list a[href*="/productos/"]');
    for (var i = 0; i < items.length; i++) {
      var h = items[i].getAttribute("href") || "";
      var m = h.match(/\/productos\/([^/?#]+)/);
      if (m) urls[m[1]] = true;
    }
    return urls;
  }

  function barajar(a) {
    var c = a.slice();
    for (var i = c.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var t = c[i]; c[i] = c[j]; c[j] = t;
    }
    return c;
  }

  function escapar(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }

  function pintar(lista) {
    var modal = document.getElementById("modal-cart");
    if (!modal) return;
    var cuerpo = modal.querySelector(".modal-body");
    var totales = cuerpo ? cuerpo.querySelector(".cart-row") : null;
    if (!cuerpo) return;

    // Si el carrito está vacío no hay nada a lo que sumarle.
    var vacio = modal.querySelector(".js-empty-ajax-cart");
    if (vacio && getComputedStyle(vacio).display !== "none") {
      var previa = modal.querySelector(".yk-reco");
      if (previa) previa.remove();
      return;
    }

    var fuera = yaEnElCarrito();
    var elegidos = barajar(lista).filter(function (p) {
      var m = (p.url || "").match(/\/productos\/([^/?#]+)/);
      return m ? !fuera[m[1]] : true;
    }).slice(0, CUANTOS);

    if (!elegidos.length) return;

    var cont = modal.querySelector(".yk-reco");
    if (!cont) {
      cont = document.createElement("div");
      cont.className = "yk-reco";
      if (totales) cuerpo.insertBefore(cont, totales);
      else cuerpo.appendChild(cont);
    }

    var html = '<p class="yk-reco-titulo">Sumá a tu compra</p><div class="yk-reco-fila">';
    for (var i = 0; i < elegidos.length; i++) {
      var p = elegidos[i];
      html += '<a class="yk-reco-item" href="' + escapar(p.url) + '">' +
        '<img loading="lazy" src="' + escapar(p.img) + '" alt="' + escapar(p.nombre) + '">' +
        '<div class="yk-reco-nombre">' + escapar(p.nombre) + "</div>" +
        '<div class="yk-reco-precio">' + escapar(p.precio) + "</div></a>";
    }
    html += "</div>";
    cont.innerHTML = html;
  }

  var pintando = false;
  function actualizar() {
    if (pintando) return;
    pintando = true;
    candidatos().then(function (lista) {
      if (lista && lista.length) pintar(lista);
      pintando = false;
    }).catch(function () { pintando = false; });
  }

  // El carrito se abre y se cierra sin recargar la página, y su contenido se
  // rehace por AJAX al agregar o quitar algo. Se vuelve a pintar cuando el
  // panel cambia, que además es lo que hace que los sugeridos salgan
  // distintos en cada apertura.
  function observar() {
    var modal = document.getElementById("modal-cart");
    if (!modal || !window.MutationObserver) return;
    var t = null;
    new MutationObserver(function () {
      clearTimeout(t);
      t = setTimeout(actualizar, 250);
    }).observe(modal, { childList: true, subtree: true, attributes: true, attributeFilter: ["class", "style"] });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () { observar(); actualizar(); });
  } else {
    observar();
    actualizar();
  }
})();
</script>
