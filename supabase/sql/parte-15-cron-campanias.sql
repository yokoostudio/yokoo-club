-- Parte 15: el cron que dispara las campañas agendadas (22/9/2026)
--
-- Corre una vez por minuto y llama a campaign-due. Si no hay ninguna campaña
-- vencida, la función devuelve enseguida sin hacer nada, así que el costo es
-- despreciable. Se necesita cada minuto (y no cada 5) porque hay envíos con
-- hora exacta: el acceso anticipado de una colección sale 19:30, no 19:33.
--
-- Para programar un mail NO se toca este cron: se inserta una fila en
-- public.campaigns con su scheduled_at. Para cambiar el texto de uno ya
-- agendado, un update a esa fila.
--
-- ⚠️ NUNCA escribir el valor real del secreto en este archivo: el repo es
-- PÚBLICO. Ya pasó una vez (17/9/2026), GitGuardian lo detectó y hubo que
-- rotarlo. Al correr esto, reemplazar el placeholder a mano en una copia
-- temporal FUERA del repo y ejecutar esa copia.

-- Borra el job anterior si existe (no falla si no existe).
select cron.unschedule(jobid) from cron.job where jobname = 'yokoo-campanias-due';

select cron.schedule(
  'yokoo-campanias-due',
  '* * * * *',
  $$
  select net.http_post(
    url := 'https://givnsohzgsugvrfuftcm.supabase.co/functions/v1/campaign-due',
    headers := '{"Content-Type":"application/json","x-yokoo-cron-secret":"REEMPLAZAR_POR_EL_CAMPAIGN_SECRET"}'::jsonb
  );
  $$
);
