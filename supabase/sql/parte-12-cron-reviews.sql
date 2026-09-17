-- Parte 12: envío automático diario de invitaciones a reseñar (17/9/2026)
--
-- Llama a la Edge Function review-invites todos los días a las 14:00 UTC
-- (11:00 de Argentina). La función se protege con CRON_SECRET, así que el
-- header tiene que coincidir con ese secreto (se setea con
-- `supabase secrets set CRON_SECRET=...`).

select cron.schedule(
  'yokoo-review-invites-diario',
  '0 14 * * *',
  $$
  select net.http_post(
    url := 'https://givnsohzgsugvrfuftcm.supabase.co/functions/v1/review-invites',
    headers := '{"Content-Type":"application/json","x-yokoo-cron-secret":"H4JxolRwAAcszpnNfYKigU5OfbRZPf"}'::jsonb
  );
  $$
);
