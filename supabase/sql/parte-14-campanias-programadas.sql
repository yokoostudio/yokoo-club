-- Parte 14: campañas programadas (22/9/2026)
--
-- Permite dejar un mail escrito y agendado para que salga solo a una hora
-- exacta, sin que nadie tenga que correr nada. Lo dispara el cron de la base
-- llamando a la Edge Function campaign-due una vez por minuto.
--
-- Por qué una tabla y no el contenido metido en el propio cron:
--   - cambiar el texto es un update a una fila, no reprogramar el cron;
--   - el secreto queda en UN solo lugar (el comando del cron), no repetido
--     en cada campaña;
--   - sirve igual para el CyberMonday sin tocar nada de esto de nuevo.

create table if not exists public.campaigns (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  subject text not null,
  -- headline, paragraphs[], images[], imageAlt, ctaText, ctaUrl, footnote
  content jsonb not null,
  scheduled_at timestamptz not null,
  -- Si tiene un mail, la campaña se manda SÓLO ahí y no cuenta como envío
  -- real (no escribe en campaign_sends). Sirve para ensayar el circuito
  -- completo, cron incluido, sin tocar a los clientes.
  test_email text,
  sent_at timestamptz,
  result jsonb,
  created_at timestamptz not null default now()
);

create index if not exists campaigns_pendientes_idx
  on public.campaigns (scheduled_at)
  where sent_at is null;

alter table public.campaigns enable row level security;

drop policy if exists "staff read campaigns" on public.campaigns;
create policy "staff read campaigns"
  on public.campaigns for select
  using (public.is_staff());
