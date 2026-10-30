{# ---------------------------------------------------------------------------
   Banner de la home: lo hace clickeable y lo cambia solo cuando termina el
   Cyber.

   TODO LO QUE PASA CUANDO TERMINA EL CYBER, EN UN SOLO LUGAR

   1) El banner no se puede clickear. El slide del panel no tiene enlace
      cargado, así que el tema no lo envuelve en un <a>: la imagen dice
      "SHOP NOW" y al tocarla no pasa nada. Acá se le superpone un enlace
      que cubre todo el banner.

   2) Las imágenes del slider se cargan desde el panel de Tiendanube, no
      desde el tema, así que no se pueden dejar programadas: alguien tiene
      que entrar y cambiarlas a mano. Juan viaja el 3 de noviembre y el
      Cyber termina el 4 a las 23:59, con lo cual la tienda se quedaría con
      el banner del Cyber puesto después de que terminó. Desde el 5 este
      código reemplaza la imagen por la de The Third Place #2.

   El banner del panel sigue estando; esto lo tapa. Cuando vuelvan del
   viaje conviene cambiarlo en el panel de verdad y borrar este archivo,
   así no queda magia escondida.

   Las imágenes nuevas tienen EXACTAMENTE la misma proporción que las del
   Cyber (2.74 en desktop, 0.82 en celular), que es la que está fijada con
   aspect-ratio en style-colors.scss. Si alguna vez se cambian por otras de
   distinta medida, hay que ajustar esos aspect-ratio o se vuelve a
   recortar.

   3) El menú lateral muestra "CyberYokoo" con un cartel NEW rojo. Pasado
      el 4 eso anuncia una promoción terminada, así que desde el 5 se
      oculta ese renglón. La categoría sigue existiendo para quien tenga
      el enlace; simplemente deja de ocupar el primer lugar del menú.

   PARA PROBARLO ANTES DE LA FECHA
     ?yk_postcyber=1   -> muestra ya el banner de The Third Place
     ?yk_postcyber=0   -> lo desactiva aunque la fecha haya pasado
--------------------------------------------------------------------------- #}
<script>
(function () {
  "use strict";

  // 5/11/2026 00:00 en Argentina (UTC-3). El país no tiene horario de
  // verano, así que la conversión es fija.
  var DESDE = Date.parse("2026-11-05T03:00:00Z");

  var BASE = "https://givnsohzgsugvrfuftcm.supabase.co/storage/v1/object/public/assets/";
  var NUEVA_DESKTOP = BASE + "banner-ttp2-desktop.jpg";
  var NUEVA_MOBILE  = BASE + "banner-ttp2-mobile.jpg";

  var DESTINO_CYBER = "/cyber-yokoo-1lt17";
  var DESTINO_DROP  = "/the-third-place";
  var ALT_DROP = "The Third Place #2 — New Collection";

  var q = new URLSearchParams(window.location.search);
  var forzado = q.get("yk_postcyber");
  var terminoElCyber = forzado === "1" || (forzado !== "0" && Date.now() >= DESDE);
  var destino = terminoElCyber ? DESTINO_DROP : DESTINO_CYBER;

  // --- 1) la imagen -------------------------------------------------------
  // El slider carga las imágenes de forma diferida: hasta que el visitante
  // llega, el src real vive en data-src/data-srcset y el src es un gif
  // transparente. Hay que pisar las cuatro y sacarle las clases de carga
  // diferida, o el tema vuelve a poner la original encima.
  function pisarImagen(img, url) {
    if (img.getAttribute("data-yk-banner") === "1") return;
    img.setAttribute("data-yk-banner", "1");
    img.removeAttribute("srcset");
    img.removeAttribute("data-srcset");
    img.setAttribute("data-src", url);
    img.src = url;
    img.alt = ALT_DROP;
    img.classList.remove("swiper-lazy", "fade-in");
  }

  // --- 2) el enlace -------------------------------------------------------
  // En vez de envolver la imagen en un <a> (mover nodos puede romper el
  // carrusel, que clona slides), se le superpone un enlace transparente que
  // cubre el slide entero. z-index 2 porque la imagen usa 1.
  function hacerClickeable(slide) {
    if (slide.querySelector(".yk-banner-link")) return;
    if (slide.closest("a") || slide.querySelector("a")) return; // ya tiene
    var cs = window.getComputedStyle(slide);
    if (cs.position === "static") slide.style.position = "relative";
    var a = document.createElement("a");
    a.className = "yk-banner-link";
    a.setAttribute("href", destino);
    a.setAttribute("aria-label", terminoElCyber ? "Ver The Third Place #2" : "Ver el CyberYokoo");
    a.style.cssText = "position:absolute; inset:0; z-index:2; display:block;";
    slide.appendChild(a);
  }

  function aplicar() {
    if (terminoElCyber) {
      var pares = [
        [".js-home-slider .slider-image", NUEVA_DESKTOP],
        [".js-home-slider-mobile .slider-image", NUEVA_MOBILE]
      ];
      for (var i = 0; i < pares.length; i++) {
        var imgs = document.querySelectorAll(pares[i][0]);
        for (var j = 0; j < imgs.length; j++) pisarImagen(imgs[j], pares[i][1]);
      }
    }

    var slides = document.querySelectorAll(
      ".js-home-slider .slider-slide, .js-home-slider-mobile .slider-slide"
    );
    for (var k = 0; k < slides.length; k++) hacerClickeable(slides[k]);

    // --- 3) el renglón del menú ------------------------------------------
    // Terminado el Cyber, "CyberYokoo NEW" en rojo queda anunciando una
    // promoción que ya no existe. Se oculta el renglón entero, no sólo el
    // cartelito: la categoría sigue existiendo para quien tenga el link,
    // pero deja de ocupar el primer lugar del menú.
    if (terminoElCyber) {
      var enMenu = document.querySelectorAll(
        '.yokoo-drawer a[href*="cyber-yokoo"], .yokoo-drawer a[href*="cyber-yokoo-1lt17"]'
      );
      for (var n = 0; n < enMenu.length; n++) enMenu[n].style.display = "none";
    }

    // Si el slide YA venía envuelto en un enlace del panel, se respeta el
    // que haya, salvo que el Cyber haya terminado: ahí apuntaría a ofertas
    // que ya no existen.
    if (terminoElCyber) {
      var enlaces = document.querySelectorAll(
        ".js-home-slider .swiper-slide > a, .js-home-slider-mobile .swiper-slide > a"
      );
      for (var m = 0; m < enlaces.length; m++) enlaces[m].setAttribute("href", DESTINO_DROP);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", aplicar);
  } else {
    aplicar();
  }

  // El carrusel se arma con JavaScript y vuelve a dibujar sus slides (al
  // rotar el teléfono, al clonar para el giro infinito). Sin esto, el
  // banner viejo reaparece y el enlace se pierde en cuanto rehace el DOM.
  if (window.MutationObserver) {
    var obs = new MutationObserver(function () { aplicar(); });
    var arrancar = function () {
      if (document.body) obs.observe(document.body, { childList: true, subtree: true });
    };
    if (document.body) arrancar();
    else document.addEventListener("DOMContentLoaded", arrancar);
  }
})();
</script>
