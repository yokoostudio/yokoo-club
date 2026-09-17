-- Parte 12: envío automático diario de invitaciones a reseñar (17/9/2026)
--
-- Llama a la Edge Function review-invites todos los días a las 14:00 UTC
-- (11:00 de Argentina). La función se protege con CRON_SECRET, así que el
-- header tiene que coincidir con ese secreto (se setea aparte con
-- `supabase secrets set CRON_SECRET=...`).
--
-- ⚠️ NUNCA escribir el valor real del secreto en este archivo: el repo es
-- PÚBLICO. Ya pasó una vez (17/9/2026): el secreto quedó commiteado acá,
-- GitGuardian lo detectó y hubo que rotarlo. Al correr esto, reemplazar el
-- placeholder a mano en una copia temporal FUERA del repo (por ejemplo en
-- /tmp) y ejecutar esa copia.

select cron.unschedule('yokoo-review-invites-diario');

select cron.schedule(
  'yokoo-review-invites-diario',
  '0 14 * * *',
  $$
  select net.http_post(
    url := 'https://givnsohzgsugvrfuftcm.supabase.co/functions/v1/review-invites',
    headers := '{"Content-Type":"application/json","x-yokoo-cron-secret":"REEMPLAZAR_POR_EL_CRON_SECRET"}'::jsonb
  );
  $$
);
