-- Parte 16: doble estrella del CyberMonday (15/10/2026)
--
-- Durante el Cyber (31/10 al 4/11) cada compra web suma DOS estrellas. La
-- segunda se guarda como una fila aparte en stamp_events con un origen propio.
--
-- Por qué un origen nuevo y no simplemente dos filas iguales: stamp_events
-- tiene UNIQUE(source, order_id) -- esa guarda es la que evita sumar dos veces
-- si Tiendanube reintenta el mismo webhook, y hay que conservarla. Con un
-- origen distinto, las dos estrellas del mismo pedido conviven sin tocar esa
-- protección, y además queda registrado en el historial cuál fue la del Cyber.
--
-- ⚠️ stamp_events.source NO es texto libre: es el enum stamp_source. Un insert
-- con un valor que no esté en el enum se rechaza, y el código que lo llama
-- puede no darse cuenta (ya pasó el 17/9 con las reseñas: la estrella no se
-- sumaba y no fallaba nada visible). Por eso esto va ANTES de desplegar las
-- funciones.

alter type public.stamp_source add value if not exists 'cyber_bonus';
