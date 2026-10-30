<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml" xmlns:og="http://opengraphprotocol.org/schema/" lang="{% for language in languages %}{% if language.active %}{{ language.lang }}{% endif %}{% endfor %}">
    <head>
        <link rel="preconnect" href="{{ store_resource_hints }}" />
        <link rel="dns-prefetch" href="{{ store_resource_hints }}" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{{ page_title }}</title>
        <meta name="description" content="{{ page_description }}" />

        {% set welcome_italic_font = settings.welcome_text and settings.welcome_italic %}
        {% set institutional_italic_font = settings.institutional_text and settings.institutional_italic %}
        {% set testimonial_italic_font = settings.testimonials_italic %}
        
        {% set italic_font = params.preview or (not params.preview and template == 'home' and welcome_italic_font or institutional_italic_font or testimonial_italic_font) %}
        {% set google_fonts_weights = italic_font ? '400,400italic,700' : '400,700' %}
        
        <link rel="preload" as="style" href="{{ [settings.font_headings, settings.font_rest] | google_fonts_url(google_fonts_weights) }}" />
        <link rel="preload" href="{{ 'css/style-critical.scss' | static_url }}" as="style" />
        <link rel="preload" href="{{ 'css/style-colors.scss' | static_url }}" as="style" />

        {# Preload LCP home, category and product page elements #}
        
        {% snipplet 'preload-images.tpl' %}

        {{ component('social-meta') }}

        {#/*============================================================================
            #CSS and fonts
        ==============================================================================*/#}

        {# Critical CSS needed to show first elements of store while CSS async is loading #}

        <style>
            {# Font families #}
            
            {{ component(
                'fonts',{
                    font_weights: google_fonts_weights,
                    font_settings: 'settings.font_headings, settings.font_rest'
                })
            }}

            {# General CSS Tokens #}

            {% include "static/css/style-tokens.tpl" %}

        </style>

        {# Critical CSS #}

        {{ 'css/style-critical.scss' | static_url | static_inline }}

        {# Colors and fonts used from settings.txt and defined on theme customization #}

        {{ 'css/style-colors.scss' | static_url | static_inline }}

        {# Load async styling not mandatory for first meaningfull paint #}

        <link rel="stylesheet" href="{{ 'css/style-async.scss' | static_url }}" media="print" onload="this.media='all'">

        {# Loads custom CSS added from Advanced Settings on the admin´s theme customization screen #}

        <style>
            {{ settings.css_code | raw }}
        </style>

        {#/*============================================================================
            #Javascript: Needed before HTML loads
        ==============================================================================*/#}

        {# Defines if async JS will be used by using script_tag(true) #}

        {% set async_js = true %}

        {# Defines the usage of jquery loaded below, if nojquery = true is deleted it will fallback to jquery 1.5 #}

        {% set nojquery = true %}

        {# Jquery async by adding script_tag(true) #}

        {% if load_jquery %}

            {{ '//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js' | script_tag(true) }}

        {% endif %}

        {# Loads private Tiendanube JS #}

        {% head_content %}

        {# Structured data to provide information for Google about the page content #}

        {{ component('structured-data-organization') }}
        {{ component('structured-data') }}

    </head>
    <body class="{% if customer %}customer-logged-in{% endif %} template-{{ template | replace('.', '-') }}">

        {# Yokoo -- lanzamiento programado de la categoría "The Third Place".
           Hasta la fecha de apertura, TODOS los enlaces que apuntan a esa
           categoría quedan ocultos en el sitio (pie de página, menús, donde
           sea) mediante CSS -- ver la regla en static/css/style-colors.scss.
           La categoría en sí sigue funcionando por URL directa: eso es a
           propósito, el link se comparte por mail a los socios del Club.

           Este script agrega la clase que DESTAPA los enlaces una vez pasada
           la fecha, así se publican solos sin que haya que tocar nada.
           Cuando termine el lanzamiento se pueden borrar estas dos piezas
           (el script y la regla del CSS) y todo queda como antes. #}
        <script>
        (function () {
            // 24/09/2026, 20:00 de Argentina (UTC-3) = 23:00 UTC.
            var APERTURA = Date.UTC(2026, 8, 24, 23, 0, 0);
            // Vista previa para nosotros: agregando ?yk_preview=1 a cualquier
            // URL se ve todo como va a quedar después de la apertura (la
            // categoría en el pie y los outfits nuevos del drop), sin esperar
            // a la hora. Borrar junto con el resto del gate post-lanzamiento.
            var vistaPrevia = location.search.indexOf('yk_preview=1') !== -1;
            if (vistaPrevia || Date.now() >= APERTURA) {
                document.documentElement.classList.add('yk-third-place-live');
            }
        })();
        </script>

        {{ component('nubesdk-slot', { type: "before_main_content" }) }}

        {# Theme icons #}

        {% include "snipplets/svg/icons.tpl" %}

        {# Facebook comments on product page #}

        {% if template == 'product' %}

            {# Facebook comment box JS #}
            {% if settings.show_product_fb_comment_box %}
                {{ fb_js }}
            {% endif %}

            {# Pinterest share button JS #}
            {{ pin_js }}

        {% endif %}

        {# Back to admin bar #}

        {{back_to_admin}}

        {# Header = Advertising + Nav + Logo + Search + Ajax Cart #}

        {% snipplet "header/header.tpl" %}

        {# Page content #}

        {% template_content %}

        {# Quickshop modal #}

        {% snipplet "grid/quick-shop.tpl" %}

        {# WhatsApp chat button #}

        {% snipplet "whatsapp-chat.tpl" %}

        {# Footer #}

        {% snipplet "footer/footer.tpl" %}

        {% if cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}

            {# Minimum used for free shipping progress messages. Located on header so it can be accesed everywhere with shipping calculator active or inactive #}

            <span class="js-ship-free-min hidden" data-pricemin="{{ cart.free_shipping.min_price_free_shipping.min_price_raw }}"></span>
            <span class="js-free-shipping-config hidden" data-config="{{ cart.free_shipping.allFreeConfigurations }}"></span>
            <span class="js-cart-subtotal hidden" data-priceraw="{{ cart.subtotal }}"></span>
            <span class="js-cart-discount hidden" data-priceraw="{{ cart.promotional_discount_amount }}"></span>
        {% endif %}

        {#/*============================================================================
            #Javascript: Needed after HTML loads
        ==============================================================================*/#}

        {# Javascript used in the store #}

        <script type="text/javascript">

            {# Libraries that do NOT depend on other libraries, e.g: Jquery #}

            {% include "static/js/external-no-dependencies.js.tpl" %}

            {# LS.ready.then function waits to Jquery and private Tiendanube JS to be loaded before executing what´s inside #}

            LS.ready.then(function(){

                {# Libraries that requires Jquery to work #}

                {% include "static/js/external.js.tpl" %}

                {# Specific store JS functions: product variants, cart, shipping, etc #}

                {% include "static/js/store.js.tpl" %}
            });
        </script>

        {# Google survey JS for Tiendanube Survey #}

        {{ component('google-survey') }}

        {# Store external codes added from admin #}

        {% if store.assorted_js %}
            <script>
                LS.ready.then(function() {
                    var trackingCode = jQueryNuvem.parseHTML('{{ store.assorted_js| escape("js") }}', document, true);
                    jQueryNuvem('body').append(trackingCode);
                });
            </script>
        {% endif %}

        {# Yokoo — cajón del menú (hamburguesa), reconstruido como
           componente 100% propio en vez de re-vestir el modal-drawer
           nativo de Tiendanube. A pedido de Juan, después de varias
           rondas donde re-vestir el nativo daba resultados que no se
           podían verificar/reproducir de forma confiable (efectos de
           cascada con reglas del tema base fuera de nuestro control) --
           esto es el MISMO código (HTML+CSS) que ya funcionaba
           perfecto en el prototipo, con los links reales de la tienda
           en vez de los de la demo. El botón de hamburguesa real del
           header se desconecta del modal nativo (se le saca
           data-toggle/js-modal-open) y se conecta a este cajón nuevo. #}
        <div class="yokoo-scrim" id="yokooScrim"></div>
        <aside class="yokoo-drawer" id="yokooDrawer">
            <div class="yokoo-drawer-blur"></div>
            <div class="yokoo-drawer-tint"></div>
            <div class="yokoo-drawer-content">
                <button type="button" class="yokoo-drawer-back" id="yokooDrawerClose" aria-label="{{ 'Cerrar menú' | translate }}">
                    <svg viewBox="0 0 38 38" fill="none"><circle cx="19" cy="19" r="15.83" stroke="currentColor" stroke-width="2"/><path d="M24.54 19H15.04" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M18.21 14.25L13.46 19L18.21 23.75" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </button>
                <nav>
                    <a href="/cyber-yokoo-1lt17" style="transition-delay:.02s">{{ 'CyberYokoo' | translate }}<span class="yokoo-drawer-new yokoo-drawer-new--cyber">{{ 'NEW' | translate }}</span></a>
                    <a href="/the-third-place" style="transition-delay:.04s">{{ 'The Third Place' | translate }}<span class="yokoo-drawer-new">{{ 'NEW' | translate }}</span></a>
                    <a href="/winter-sale/" style="transition-delay:.06s">{{ 'Winter Sale' | translate }}</a>
                    <a href="/bestsellers/" style="transition-delay:.08s">{{ 'Bestsellers' | translate }}</a>
                    <a href="/back-to-basics/" style="transition-delay:.12s">{{ 'Back to Basics' | translate }}</a>
                    <a href="/colecciones/" style="transition-delay:.16s">{{ 'Colecciones' | translate }}</a>
                </nav>
                <div class="yokoo-drawer-gap"></div>
                <nav class="yokoo-drawer-cats">
                    <a href="/shop/remeras/" style="transition-delay:.2s">{{ 'Remeras' | translate }}</a>
                    <a href="/shop/buzos/" style="transition-delay:.23s">{{ 'Hoodies' | translate }}</a>
                    <a href="/shop/sweaters/" style="transition-delay:.26s">{{ 'Sweaters' | translate }}</a>
                    <a href="/shop/camisas/" style="transition-delay:.29s">{{ 'Camisas' | translate }}</a>
                    <a href="/shop/jeans/" style="transition-delay:.32s">{{ 'Pantalones' | translate }}</a>
                    <a href="/shop/tank-top/" style="transition-delay:.35s">{{ 'Tank Top' | translate }}</a>
                    <a href="/shop/packs/" style="transition-delay:.38s">{{ 'Packs' | translate }}</a>
                    <a href="/shop/accesorios/" style="transition-delay:.41s">{{ 'Accesorios' | translate }}</a>
                </nav>
                <svg class="yokoo-drawer-star" viewBox="0 0 31.02 29.3" fill="#fff"><path d="M17.9346 0.402702L18.6192 10.7479C18.6192 10.7542 18.6242 10.7592 18.6305 10.7598L30.6527 12.5212C31.081 12.5837 31.1598 13.1678 30.7634 13.3416L19.0382 18.4932C19.0301 18.497 19.0276 18.5076 19.0338 18.5139L27.8965 28.2588C28.2116 28.6052 27.8258 29.1349 27.3994 28.941L14.1516 22.9133C14.146 22.9108 14.1391 22.9127 14.136 22.9171L9.40452 29.1273C9.13253 29.4844 8.56415 29.2393 8.63668 28.7966L10.3612 18.2625C10.3624 18.255 10.3574 18.2488 10.3499 18.2475L0.366753 16.7456C-0.069066 16.6799 -0.136596 16.0797 0.273586 15.9184L13.4838 10.731C13.4876 10.7298 13.4901 10.7267 13.4913 10.7229L17.0979 0.290152C17.2518 -0.153796 17.9039 -0.0662567 17.9352 0.402702H17.9346Z"></path></svg>
                <div class="yokoo-drawer-footer">
                    <a href="/account/login/">{{ 'Iniciar sesión' | translate }}</a> . <a href="/account/register">{{ 'Crear cuenta' | translate }}</a>
                </div>
            </div>
        </aside>
        <script>
        (function(){
            var scrim = document.getElementById('yokooScrim');
            var drawer = document.getElementById('yokooDrawer');
            var closeBtn = document.getElementById('yokooDrawerClose');
            if (!scrim || !drawer || !closeBtn) return;

            function openDrawer(){
                scrim.classList.add('show');
                drawer.classList.add('show');
            }
            function closeDrawer(){
                scrim.classList.remove('show');
                drawer.classList.remove('show');
            }

            var menuBtn = document.querySelector('[data-toggle="#nav-hamburger"]');
            if (menuBtn) {
                menuBtn.removeAttribute('data-toggle');
                menuBtn.removeAttribute('data-modal-url');
                menuBtn.classList.remove('js-modal-open');
                menuBtn.addEventListener('click', function(e){
                    e.preventDefault();
                    openDrawer();
                });
            }
            closeBtn.addEventListener('click', closeDrawer);
            scrim.addEventListener('click', closeDrawer);
        })();
        </script>

        {# Yokoo — botón de "compra rápida" como ícono circular de vidrio
           sobre la foto de cada card de producto (home, categorías,
           buscador), en vez del link de texto "Comprar" debajo del
           precio. No se crea ningún botón nuevo: se MUEVE el trigger real
           que ya existe (el mismo que abre el popup nativo de compra
           rápida, o el submit directo cuando el producto no tiene
           variantes), así que el click sigue siendo 100% funcional -- acá
           solo se reposiciona+re-viste con CSS (ver style-colors.scss).
           Se excluyen a propósito las cards de "Productos similares" de
           la página de Producto (.js-related-products), que ya tienen su
           propio tratamiento de texto en negrita aprobado aparte.
           Corre en cada card ya presente al cargar y también en las que
           se agregan después (paginación infinita / AJAX) vía
           MutationObserver. #}
        <script>
        (function(){
            function yokooMoveQuickAdd(card){
                if (!card || card.dataset.yokooQaDone) return;
                if (card.closest('.js-related-products')) return;
                var imgBox = card.querySelector('.item-image');
                var actions = card.querySelector('.item-actions');
                if (!imgBox || !actions) return;
                imgBox.appendChild(actions);
                card.dataset.yokooQaDone = '1';
            }

            {# Yokoo — selector de talle en popover (como en el prototipo):
               en vez de dejar que el click abra el modal grande nativo de
               compra rápida, mostramos ACÁ MISMO el formulario real que
               el tema ya arma oculto por card (.js-item-variants -- los
               mismos talles + el mismo botón "Agregar al carrito" que
               usa el modal, ni una línea de lógica de carrito nueva).
               Sólo aplica a productos CON variantes; los que agregan
               directo (sin talle) siguen funcionando como ya estaban. #}
            function yokooSetupSizePopover(card){
                if (!card || card.dataset.yokooSpDone) return;
                if (card.closest('.js-related-products')) return;
                var trigger = card.querySelector('.js-quickshop-modal-open');
                var variants = card.querySelector('.js-item-variants');
                var imgBox = card.querySelector('.item-image');
                if (!trigger || !variants || !imgBox) return;
                trigger.removeAttribute('data-toggle');
                trigger.removeAttribute('data-modal-url');
                trigger.classList.remove('js-modal-open', 'js-fullscreen-modal-open', 'js-quickshop-slide');
                variants.classList.add('yokoo-size-popover');
                {# Yokoo -- el popover se muda a document.body más abajo, así
                   que pierde la relación de DOM con su tarjeta. Guardamos la
                   referencia acá para que el cartelito de "agregado al
                   carrito" (más abajo en este archivo) pueda sacar foto,
                   nombre y precio del producto correcto. #}
                variants.__yokooCard = card;
                {# Yokoo — mismo bug real de Chrome que después se
                   encontró en el cajón del carrito: background-color +
                   backdrop-filter juntos en un elemento con
                   border-radius pintaban la FOTO DEL PRODUCTO detrás del
                   popover lavada/casi transparente en vez de quedar
                   tapada por un panel opaco (reportado por Juan con
                   video). Se separa en dos capas propias (blur atrás,
                   tinte adelante) + todo el contenido real del
                   formulario envuelto en su propio contenedor, así
                   queda siempre arriba de las dos por z-index sin
                   depender del orden interno del HTML nativo. #}
                var popBlur = document.createElement('div');
                popBlur.className = 'yokoo-size-popover-blur';
                var popTint = document.createElement('div');
                popTint.className = 'yokoo-size-popover-tint';
                var popContent = document.createElement('div');
                popContent.className = 'yokoo-size-popover-content';
                while (variants.firstChild) {
                    popContent.appendChild(variants.firstChild);
                }
                variants.appendChild(popBlur);
                variants.appendChild(popTint);
                variants.appendChild(popContent);
                {# Yokoo — el popover se mueve a document.body (en vez de
                   quedar adentro de .item-image) porque .item-image tiene
                   overflow:hidden (necesario para las esquinas redondeadas
                   de la foto): un hijo posicionado arriba del círculo de
                   compra rápida quedaba recortado y 100% invisible, aunque
                   el click sí funcionaba por dentro -- bug real reportado
                   por Juan como "al apretarlo no me hace nada". Con
                   position:fixed + posición calculada en cada apertura no
                   hay contenedor que lo recorte. #}
                document.body.appendChild(variants);
                {# Posición calculada con límites de pantalla: por defecto
                   ancla arriba-a-la-derecha del círculo (como el
                   prototipo), pero si eso lo saca de la pantalla (cards de
                   la primera columna, o pegadas arriba del todo cerca del
                   header) lo desplaza para que quede siempre 100%
                   visible. #}
                function yokooPositionPopover(){
                    var r = trigger.getBoundingClientRect();
                    var margin = 12;
                    variants.style.visibility = 'hidden';
                    variants.style.display = 'block';
                    var w = variants.offsetWidth;
                    var h = variants.offsetHeight;
                    var left = r.right - w;
                    left = Math.max(margin, Math.min(left, window.innerWidth - margin - w));
                    var top = r.top - h - 10;
                    if (top < margin) top = r.bottom + 10;
                    variants.style.left = left + 'px';
                    variants.style.top = top + 'px';
                    variants.style.display = '';
                    variants.style.visibility = '';
                }
                trigger.addEventListener('click', function(e){
                    e.preventDefault();
                    e.stopPropagation();
                    var wasOpen = variants.classList.contains('show');
                    document.querySelectorAll('.yokoo-size-popover.show').forEach(function(v){ v.classList.remove('show'); });
                    if (!wasOpen) {
                        variants.classList.remove('hidden');
                        yokooPositionPopover();
                        variants.classList.add('show');
                    }
                });
                card.dataset.yokooSpDone = '1';
            }

            function yokooInitCard(card){
                yokooMoveQuickAdd(card);
                yokooSetupSizePopover(card);
            }

            document.querySelectorAll('.js-item-product').forEach(yokooInitCard);

            document.addEventListener('click', function(e){
                if (!e.target.closest('.yokoo-size-popover') && !e.target.closest('.js-quickshop-modal-open')) {
                    document.querySelectorAll('.yokoo-size-popover.show').forEach(function(v){ v.classList.remove('show'); });
                }
            });
            {# Se cierra al scrollear: como ahora vive en document.body con
               position:fixed calculada al abrir, no re-sigue al trigger si
               la página se mueve mientras está abierto. #}
            window.addEventListener('scroll', function(){
                document.querySelectorAll('.yokoo-size-popover.show').forEach(function(v){ v.classList.remove('show'); });
            }, {passive: true});

            if (window.MutationObserver) {
                new MutationObserver(function(mutations){
                    mutations.forEach(function(m){
                        m.addedNodes.forEach(function(node){
                            if (node.nodeType !== 1) return;
                            if (node.matches && node.matches('.js-item-product')) yokooInitCard(node);
                            if (node.querySelectorAll) node.querySelectorAll('.js-item-product').forEach(yokooInitCard);
                        });
                    });
                }).observe(document.body, {childList: true, subtree: true});
            }
        })();
        </script>

        {# Yokoo — fila de categorías del header: se activa (clase
           "post-banner" en el header) al scrollear pasado el banner
           principal de la Home. Si no hay banner de home en la página
           (cualquier otra página del sitio), simplemente no hace nada y
           la fila queda siempre colapsada -- no hace falta un chequeo de
           template aparte. #}
        <script>
        (function(){
            var headerEl = document.querySelector('.js-head-main');
            var hero = document.querySelector('.js-home-slider-section');
            if (headerEl && hero) {
                {# Home: mismo comportamiento de siempre -- arranca
                   transparente y se expande/desenfoca al pasar el banner. #}
                function yokooUpdateHeaderCatState(){
                    var pastHero = hero.getBoundingClientRect().bottom <= 0;
                    headerEl.classList.toggle('post-banner', pastHero);
                }
                window.addEventListener('scroll', yokooUpdateHeaderCatState, {passive: true});
                yokooUpdateHeaderCatState();
            } else if (headerEl) {
                {# Yokoo — Producto, Categorías y cualquier otra página sin
                   banner: a pedido de Juan, el header queda SIEMPRE con
                   las categorías desplegadas y el vidrio esmerilado
                   activo (mejor navegación) -- no depende de scroll acá,
                   se prende una sola vez al cargar. #}
                headerEl.classList.add('post-banner');
            }
            var catLinks = document.querySelectorAll('#headCategories a');
            catLinks.forEach(function(link){
                link.addEventListener('click', function(){
                    catLinks.forEach(function(l){ l.classList.remove('active'); });
                    link.classList.add('active');
                });
            });
        })();
        </script>

        {# Yokoo — Carrito de compras como cajón propio (mismo patrón que
           el menú lateral): el panel nativo de Tiendanube (#modal-cart)
           sigue existiendo y sigue recibiendo TODAS las actualizaciones
           reales del carrito (agregar, sacar, cambiar cantidad -- las
           funciones nativas LS.plusQuantity/minusQuantity/removeItem son
           globales y no dependen de en qué parte del DOM viva el
           formulario), pero nunca se muestra: su contenido real (el
           <form class="js-ajax-cart-panel"> completo, con ítems, barra
           de envío gratis, subtotal/total y botón de checkout reales) se
           TRASLADA una sola vez a este cajón (ver style-colors.scss para
           el re-vestido visual completo). Probado en vivo antes de
           implementar: una actualización de cantidad, un remove, e
           incluso agregar un producto totalmente distinto después de
           mover el formulario siguen actualizando todo correctamente --
           las funciones de Tiendanube buscan los elementos por clase en
           todo el documento, no dependen de la ubicación física. #}
        <div class="yokoo-cart-scrim" id="yokooCartScrim"></div>
        {# Yokoo -- el fondo oscuro y el desenfoque del cajón se separan en
           dos capas propias (.yokoo-cart-drawer-blur / -tint) en vez de
           poner background+backdrop-filter juntos en el mismo elemento.
           Bug real reportado por Juan con video: en su Chrome, esa
           combinación en un único elemento con border-radius+overflow:
           hidden pintaba el centro del cajón CLARO (solo el borde salía
           oscuro) -- un problema real de cómo compone ese navegador,
           aunque en las pruebas de esta sesión no se veía así siempre.
           Separarlo en capas es la forma robusta estándar de evitarlo. #}
        <aside class="yokoo-cart-drawer" id="yokooCartDrawer">
            <div class="yokoo-cart-drawer-blur"></div>
            <div class="yokoo-cart-drawer-tint"></div>
            <button type="button" class="yokoo-cart-close" id="yokooCartClose" aria-label="{{ 'Cerrar carrito' | translate }}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
            <h3 class="yokoo-cart-title">{{ 'Tu carrito' | translate }}</h3>
            <div class="yokoo-cart-slot" id="yokooCartSlot"></div>
        </aside>
        <script>
        (function(){
            var nativeModal = document.getElementById('modal-cart');
            var cartTrigger = document.querySelector('[data-toggle="#modal-cart"]');
            var scrim = document.getElementById('yokooCartScrim');
            var drawer = document.getElementById('yokooCartDrawer');
            var closeBtn = document.getElementById('yokooCartClose');
            var slot = document.getElementById('yokooCartSlot');
            if (!nativeModal || !cartTrigger || !scrim || !drawer || !slot) return;

            var relocated = false;
            function relocateCartForm(){
                if (relocated) return;
                var form = nativeModal.querySelector('form.js-ajax-cart-panel');
                if (!form) return;
                slot.appendChild(form);
                relocated = true;
            }

            {# Yokoo -- Tiendanube tiene OTROS modales nativos además del
               carrito (ej. el de "descuento exclusivo" por venta cruzada,
               id #js-cross-selling-modal) que comparten el mismo overlay
               compartido (.modal-overlay -- en realidad hay UNO por cada
               modal nativo, cada uno marcado con data-modal-id="#id-del-
               modal"). La causa real y confirmada del bug reportado por
               Juan ("se me puso toda la pantalla desenfocada de la nada
               al apretar el carrito"): al clickear el ícono del carrito
               del header, Tiendanube dispara por su cuenta el flujo del
               modal de venta cruzada, que le saca el "display:none"
               inline a SU overlay -- pero el modal en sí nunca llega a
               mostrarse (le falta contenido para ese producto), así que
               el overlay queda flotando solo, con blur, sin nada debajo.
               OJO: la versión anterior de esta función usaba
               overlay.style.removeProperty('display') pensando que así
               volvía a su estado "oculto por defecto" -- pero el CSS
               base de .modal-overlay es display:block, así que sacarle
               el inline display:none es exactamente lo que lo REVELA.
               Por eso el bug persistía pese a llamar esta función. Fix:
               por cada overlay nativo, sólo lo dejamos visible si su
               modal asociado (via data-modal-id) realmente tiene la
               clase modal-show; si no, se le fuerza display:none con
               !important explícito. Como también puede pasar que el
               modal de venta cruzada dispare su apertura DESPUÉS de que
               esta función ya corrió (código nativo async), se vuelve a
               llamar con timeouts cortos tras abrir/cerrar el cajón. #}
            function forceCleanupNativeModals(){
                document.querySelectorAll('.modal.modal-show').forEach(function(m){
                    m.classList.remove('modal-show');
                });
                document.querySelectorAll('.modal-overlay').forEach(function(overlay){
                    var targetSel = overlay.getAttribute('data-modal-id');
                    var target = targetSel ? document.querySelector(targetSel) : null;
                    var targetVisible = target && target.classList.contains('modal-show');
                    if (!targetVisible) {
                        overlay.style.setProperty('display', 'none', 'important');
                        overlay.classList.remove('show');
                    }
                });
                document.body.classList.remove('overflow-none', 'move-right');
            }
            function openCart(){
                forceCleanupNativeModals();
                relocateCartForm();
                drawer.classList.add('show');
                scrim.classList.add('show');
                [0, 60, 200, 500, 1000].forEach(function(ms){
                    setTimeout(forceCleanupNativeModals, ms);
                });
            }
            function closeCart(){
                drawer.classList.remove('show');
                scrim.classList.remove('show');
                forceCleanupNativeModals();
            }
            {# Yokoo -- se expone para que el cartelito de "agregado al
               carrito" (otro bloque de este mismo archivo) pueda abrir el
               cajón sin duplicar toda esta lógica. #}
            window.yokooOpenCart = openCart;
            {# Yokoo -- Juan reportó que la página se desenfocaba de más
               al apretar el botón del carrito (además del blur propio,
               esperado, de nuestro .yokoo-cart-scrim). Causa real: el
               botón todavía tenía las clases/atributos nativos
               (data-toggle, js-modal-open, js-fullscreen-modal-open),
               así que CADA click también disparaba el sistema de modal
               nativo de Tiendanube por su cuenta (mismo overlay
               compartido con blur propio), sumándose al nuestro. El
               contenido real (#modal-cart) ya está armado en el HTML
               desde que carga la página -- no hace falta esperar
               ningún fetch, así que no hay ningún motivo para dejar
               que su lógica de apertura corra más. Se lo desconecta
               del todo, mismo tratamiento que ya se le había hecho al
               botón de hamburguesa. #}
            cartTrigger.removeAttribute('data-toggle');
            cartTrigger.removeAttribute('data-modal-url');
            cartTrigger.classList.remove('js-modal-open', 'js-fullscreen-modal-open');
            cartTrigger.addEventListener('click', openCart);
            closeBtn.addEventListener('click', closeCart);
            scrim.addEventListener('click', closeCart);
            {# Si se abre el menú lateral (#yokooDrawer, definido en otro
               bloque de este mismo archivo) mientras el carrito está
               abierto, lo cerramos -- evita dos cajones superpuestos. Se
               observa la clase en vez de depender de una referencia
               compartida al botón de hamburguesa (ese script ya le sacó
               el atributo data-toggle que usaríamos para volver a
               encontrarlo). #}
            var menuDrawer = document.getElementById('yokooDrawer');
            if (menuDrawer && window.MutationObserver) {
                new MutationObserver(function(){
                    if (menuDrawer.classList.contains('show')) closeCart();
                }).observe(menuDrawer, {attributes: true, attributeFilter: ['class']});
            }
        })();
        </script>
        <script>
        (function(){
            {# Yokoo -- pop-up nativo de venta cruzada ("¡Descuento
               exclusivo!"), mismo tratamiento de vidrio que el menú y el
               carrito: dos capas propias (blur atrás, tinte adelante,
               mismo motivo que en esos dos casos -- ver comentario en
               .yokoo-cart-drawer-blur del CSS) inyectadas como primeros
               hijos del modal nativo (#js-cross-selling-modal ya existe
               en el HTML desde que carga la página, aunque su contenido
               interno se rellena después por AJAX recién cuando
               corresponde mostrar una oferta). #}
            var modal = document.getElementById('js-cross-selling-modal');
            if (!modal) return;
            var blur = document.createElement('div');
            blur.className = 'yokoo-crosssell-blur';
            var tint = document.createElement('div');
            tint.className = 'yokoo-crosssell-tint';
            modal.insertBefore(tint, modal.firstChild);
            modal.insertBefore(blur, modal.firstChild);
        })();
        </script>
        {# Yokoo -- pop-up "Yokoo Members" (invitación a la tarjeta de
           fidelidad real, ver yokoo-club en GitHub Pages): mismo lenguaje
           visual glass que el menú/carrito, con la paleta propia del club
           (manteca/crema sobre café) para que se note la conexión con la
           app. Solo invita y linkea -- no consulta si el visitante ya es
           socio (esa versión "conectada" queda para más adelante). #}
        <div class="yokoo-members-scrim" id="yokooMembersScrim"></div>
        <aside class="yokoo-members-popup" id="yokooMembersPopup">
            <div class="yokoo-members-popup-blur"></div>
            <div class="yokoo-members-popup-tint"></div>
            <button type="button" class="yokoo-members-close" id="yokooMembersClose" aria-label="{{ 'Cerrar' | translate }}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
            <div class="yokoo-members-content">
                <p class="yokoo-members-eyebrow">Yokoo Members</p>
                <div class="yokoo-members-stars" aria-hidden="true">
                    <svg viewBox="0 0 24 24"><path d="M12 2l2.9 6.9 7.1.6-5.4 4.9 1.6 7.6L12 17.8l-6.2 4.2 1.6-7.6L2 8.5l7.1-.6L12 2z"/></svg>
                    <svg viewBox="0 0 24 24"><path d="M12 2l2.9 6.9 7.1.6-5.4 4.9 1.6 7.6L12 17.8l-6.2 4.2 1.6-7.6L2 8.5l7.1-.6L12 2z"/></svg>
                    <svg viewBox="0 0 24 24"><path d="M12 2l2.9 6.9 7.1.6-5.4 4.9 1.6 7.6L12 17.8l-6.2 4.2 1.6-7.6L2 8.5l7.1-.6L12 2z"/></svg>
                    <svg viewBox="0 0 24 24"><path d="M12 2l2.9 6.9 7.1.6-5.4 4.9 1.6 7.6L12 17.8l-6.2 4.2 1.6-7.6L2 8.5l7.1-.6L12 2z"/></svg>
                    <svg viewBox="0 0 24 24"><path d="M12 2l2.9 6.9 7.1.6-5.4 4.9 1.6 7.6L12 17.8l-6.2 4.2 1.6-7.6L2 8.5l7.1-.6L12 2z"/></svg>
                </div>
                <h3 class="yokoo-members-title">{{ 'Sumá estrellas y llevate un descuento exclusivo' | translate }}</h3>
                <p class="yokoo-members-body">{{ 'Registrate gratis en Yokoo Members: te mandamos un cupón de descuento exclusivo de bienvenida y empezás a sumar estrellas en cada compra para ganar premios sorpresa. Además recibís novedades y promos por mail.' | translate }}</p>
                <a class="yokoo-members-cta" href="https://yokoostudio.github.io/yokoo-club/" target="_blank" rel="noopener">{{ 'Quiero mi descuento' | translate }}</a>
                <p class="yokoo-members-fineprint">{{ 'Es gratis y tarda menos de un minuto' | translate }}</p>
            </div>
        </aside>
        <script>
        (function(){
            {# Yokoo -- aparece solo en la home, una vez por día por
               visitante (localStorage), con una demora chica para no
               tapar la carga inicial de la página. Se cierra solo si el
               visitante abre el carrito o el menú mientras está abierto
               (mismo criterio ya usado entre cajones), y no se muestra
               si alguno de esos dos ya está abierto en el momento en que
               le toca aparecer. #}
            if (!document.body.classList.contains('template-home')) return;
            // Yokoo -- pausado durante la campaña del Cyber (26/10 al 1/11, hora
            // de Argentina): esos días la barra roja del Cyber es el único pedido
            // de registro, para no superponer dos mensajes. Se reactiva solo.
            var _hoy = Date.now();
            if (_hoy >= Date.parse('2026-10-26T03:00:00Z') && _hoy <= Date.parse('2026-11-02T02:59:59Z')) return;
            var popup = document.getElementById('yokooMembersPopup');
            var scrim = document.getElementById('yokooMembersScrim');
            var closeBtn = document.getElementById('yokooMembersClose');
            if (!popup || !scrim || !closeBtn) return;
            var STORAGE_KEY = 'yokooMembersPopupLastShown';
            var ONE_DAY = 24 * 60 * 60 * 1000;
            function shouldShow(){
                try {
                    var last = localStorage.getItem(STORAGE_KEY);
                    return !last || (Date.now() - parseInt(last, 10)) > ONE_DAY;
                } catch (e) {
                    return true;
                }
            }
            function otherPanelOpen(){
                var cart = document.getElementById('yokooCartDrawer');
                var menu = document.getElementById('yokooDrawer');
                return (cart && cart.classList.contains('show')) || (menu && menu.classList.contains('show'));
            }
            function openPopup(){
                popup.classList.add('show');
                scrim.classList.add('show');
                try { localStorage.setItem(STORAGE_KEY, String(Date.now())); } catch (e) {}
            }
            function closePopup(){
                popup.classList.remove('show');
                scrim.classList.remove('show');
            }
            closeBtn.addEventListener('click', closePopup);
            scrim.addEventListener('click', closePopup);
            ['yokooCartDrawer', 'yokooDrawer'].forEach(function(id){
                var el = document.getElementById(id);
                if (el && window.MutationObserver) {
                    new MutationObserver(function(){
                        if (el.classList.contains('show')) closePopup();
                    }).observe(el, {attributes: true, attributeFilter: ['class']});
                }
            });
            if (shouldShow()) {
                setTimeout(function(){
                    if (!otherPanelOpen()) openPopup();
                }, 2500);
            }
        })();
        </script>
        {# Yokoo -- cartelito propio de "agregado al carrito", reemplaza a la
           notificación nativa (.js-alert-added-to-cart, oculta por CSS).
           Motivo real: esa notificación nativa quedaba con TODOS sus campos
           vacíos (src="", nombre, cantidad y precio en blanco -- por eso se
           veía el ícono de imagen rota y una "x" suelta, reportado por Juan
           con captura). La causa es nuestro propio rediseño: al reemplazar la
           compra rápida nativa por el popover de talles, el JS nativo que
           rellena esos campos se quedó sin los datos que esperaba. En vez de
           pelear con esa lógica interna, se arma el cartel con los datos que
           ya tenemos en la página. #}
        <div class="yokoo-toast" id="yokooToast" role="status" aria-live="polite">
            <div class="yokoo-toast-blur"></div>
            <div class="yokoo-toast-tint"></div>
            <button type="button" class="yokoo-toast-close" id="yokooToastClose" aria-label="{{ 'Cerrar' | translate }}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
            <div class="yokoo-toast-content">
                <div class="yokoo-toast-thumb"><img class="yokoo-toast-img" src="" alt="" /></div>
                <div class="yokoo-toast-text">
                    <p class="yokoo-toast-eyebrow">{{ 'Agregado al carrito' | translate }}</p>
                    <p class="yokoo-toast-name"></p>
                    <p class="yokoo-toast-meta"></p>
                </div>
            </div>
            <button type="button" class="yokoo-toast-cta" id="yokooToastCta">{{ 'Ver mi carrito' | translate }}</button>
        </div>
        <script>
        (function(){
            var toast = document.getElementById('yokooToast');
            var badge = document.querySelector('.js-cart-widget-amount');
            if (!toast || !badge) return;

            var imgEl = toast.querySelector('.yokoo-toast-img');
            var thumbEl = toast.querySelector('.yokoo-toast-thumb');
            var nameEl = toast.querySelector('.yokoo-toast-name');
            var metaEl = toast.querySelector('.yokoo-toast-meta');
            var hideTimer = null;
            var pending = null;

            function clean(t){ return (t || '').replace(/\s+/g, ' ').trim(); }

            {# Las fotos del catálogo usan lazysizes: mientras no entraron en
               pantalla, su "src" es un gif transparente de 1px y la URL real
               vive en data-srcset. Se elige la primera variante de al menos
               240px de ancho para que no salga pixelada en el cartel. #}
            function bestImage(img){
                if (!img) return '';
                var src = img.currentSrc || img.getAttribute('src') || '';
                if (src && src.indexOf('data:') !== 0) return src;
                var set = img.getAttribute('data-srcset') || img.getAttribute('srcset') || '';
                if (!set) return img.getAttribute('data-src') || '';
                var parts = set.split(',');
                var chosen = '';
                for (var i = 0; i < parts.length; i++) {
                    var bits = clean(parts[i]).split(' ');
                    chosen = bits[0];
                    if (parseInt(bits[1] || '0', 10) >= 240) break;
                }
                return chosen;
            }

            function collect(btn){
                var pop = btn.closest ? btn.closest('.yokoo-size-popover') : null;
                var card = (pop && pop.__yokooCard) ? pop.__yokooCard : (btn.closest ? btn.closest('.js-item-product') : null);
                var info = { img: '', name: '', price: '', size: '' };

                if (card) {
                    info.img = bestImage(card.querySelector('img.js-item-image') || card.querySelector('img'));
                    info.name = clean((card.querySelector('.js-item-name') || {}).textContent);
                    info.price = clean((card.querySelector('.js-price-display') || {}).textContent);
                } else {
                    info.img = bestImage(document.querySelector('.js-product-slide-img'));
                    info.name = clean((document.querySelector('.js-product-name') || document.querySelector('h1') || {}).textContent);
                    info.price = clean((document.querySelector('.js-price-display') || {}).textContent);
                }

                var scope = pop || card || document;
                var variation = scope.querySelector('.js-variation-option');
                if (variation && variation.value) info.size = clean(variation.value);

                return info;
            }

            function show(info){
                if (info.img) {
                    imgEl.setAttribute('src', info.img);
                    thumbEl.hidden = false;
                } else {
                    thumbEl.hidden = true;
                }
                nameEl.textContent = info.name || '';
                metaEl.textContent = [info.size ? 'Talle ' + info.size : '', info.price].filter(Boolean).join(' · ');
                toast.classList.add('show');
                clearTimeout(hideTimer);
                hideTimer = setTimeout(hide, 4500);
            }

            function hide(){
                toast.classList.remove('show');
                clearTimeout(hideTimer);
            }

            {# Se captura el contexto en el momento del click (ahí sabemos de
               qué tarjeta salió), pero el cartel recién se muestra cuando el
               contador del carrito sube de verdad -- así nunca aparece si el
               agregado falla. #}
            document.addEventListener('click', function(e){
                var btn = e.target.closest ? e.target.closest('.js-addtocart') : null;
                if (btn) pending = collect(btn);
            }, true);

            var lastCount = parseInt(clean(badge.textContent) || '0', 10);
            new MutationObserver(function(){
                var count = parseInt(clean(badge.textContent) || '0', 10);
                if (isNaN(count) || count <= lastCount) { lastCount = isNaN(count) ? lastCount : count; return; }
                lastCount = count;

                badge.classList.remove('yokoo-bump');
                void badge.offsetWidth; {# reinicia la animación si se agregan dos productos seguidos #}
                badge.classList.add('yokoo-bump');

                show(pending || { img: '', name: '', price: '', size: '' });
                pending = null;
            }).observe(badge, { childList: true, characterData: true, subtree: true });

            document.getElementById('yokooToastClose').addEventListener('click', hide);
            document.getElementById('yokooToastCta').addEventListener('click', function(){
                hide();
                if (typeof window.yokooOpenCart === 'function') window.yokooOpenCart();
            });

            {# Si el cliente abre el carrito o el menú, el cartel sobra. #}
            ['yokooCartDrawer', 'yokooDrawer'].forEach(function(id){
                var el = document.getElementById(id);
                if (el && window.MutationObserver) {
                    new MutationObserver(function(){
                        if (el.classList.contains('show')) hide();
                    }).observe(el, { attributes: true, attributeFilter: ['class'] });
                }
            });
        })();
        </script>

        {% include "snipplets/yk-stock-badge.tpl" %}
        {% include "snipplets/yk-cyber-gate.tpl" %}
    </body>
</html>
