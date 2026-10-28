-- Parte 20: disparo automático de los códigos de Navidad (26/10/2026)
--
-- Corre UNA vez, el jueves 12/11 a las 13:00 UTC (10:00 de Argentina). Juan
-- está de viaje desde el 3, así que esto tiene que salir solo.
--
-- Estaba puesto para el sábado 7 y se movió al 12 el 27/10, a pedido de Juan.
--
-- La función es idempotente (la tabla navidad_codigos evita mandar dos veces),
-- así que si hiciera falta volver a correrla sólo le manda a quien falte.
--
-- ⚠️ NUNCA escribir el valor real del secreto en este archivo: el repo es
-- PÚBLICO. Reemplazar el placeholder en una copia temporal FUERA del repo y
-- ejecutar esa copia. El valor está en .secrets/campaign-secret.txt
--
-- Después del 12 conviene borrar el job:
--   select cron.unschedule(jobid) from cron.job where jobname = 'yokoo-navidad-codigos';

select cron.unschedule(jobid) from cron.job where jobname = 'yokoo-navidad-codigos';

select cron.schedule(
  'yokoo-navidad-codigos',
  '0 13 12 11 *',
  $$
  select net.http_post(
    url := 'https://givnsohzgsugvrfuftcm.supabase.co/functions/v1/navidad-codigos',
    headers := '{"Content-Type":"application/json","x-yokoo-cron-secret":"REEMPLAZAR_POR_EL_CAMPAIGN_SECRET"}'::jsonb
  );
  $$
);
