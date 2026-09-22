-- Parte 13: envíos de campaña a toda la lista del Club (22/9/2026)
--
-- Da soporte a la Edge Function campaign-send: mails masivos (lanzamiento de
-- colección, CyberMonday, etc.) con la plantilla de marca, a diferencia de los
-- mails transaccionales de a uno que ya existían.
--
-- Dos cosas:
--   1. customers.unsubscribed -- quien se da de baja de las campañas SIGUE
--      recibiendo los mails transaccionales (login, estrella, cupón): son otra
--      cosa y los pidió explícitamente al usar la app.
--   2. campaign_sends -- una fila por (campaña, mail) efectivamente enviado.
--      El UNIQUE es la guarda anti-duplicado: si una corrida se corta por la
--      mitad, la siguiente sólo manda a quien faltaba.

alter table public.customers
  add column if not exists unsubscribed boolean not null default false;

create table if not exists public.campaign_sends (
  id uuid primary key default gen_random_uuid(),
  campaign_slug text not null,
  email text not null,
  sent_at timestamptz not null default now(),
  unique (campaign_slug, email)
);

create index if not exists campaign_sends_slug_idx
  on public.campaign_sends (campaign_slug);

alter table public.campaign_sends enable row level security;

-- Sólo el staff puede mirar el historial de envíos desde el panel. Las Edge
-- Functions escriben con service_role, que ignora RLS (mismo patrón que
-- reviews en la parte 11).
drop policy if exists "staff read campaign_sends" on public.campaign_sends;
create policy "staff read campaign_sends"
  on public.campaign_sends for select
  using (public.is_staff());
