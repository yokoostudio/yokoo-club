-- Parte 11: sistema de reseñas de clientes (17/9/2026)
--
-- Una fila por compra elegible: se crea cuando se manda la invitación
-- (~14 días después de la compra) y se completa cuando el cliente escribe
-- su reseña usando el link único del mail. El cupón de 10% se emite recién
-- al enviarla.

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  order_id text not null unique,
  customer_email text not null,
  customer_name text,
  token text not null unique,
  invited_at timestamptz,
  submitted_at timestamptz,
  rating int check (rating between 1 and 5),
  comment text,
  status text not null default 'pending',
  coupon_code text
);

create index if not exists reviews_status_idx on public.reviews (status);
create index if not exists reviews_submitted_idx on public.reviews (submitted_at);

alter table public.reviews enable row level security;

-- Sólo el staff ve y modera desde el panel Negocio. Las Edge Functions
-- usan service_role, que ignora RLS.
drop policy if exists "staff read reviews" on public.reviews;
create policy "staff read reviews" on public.reviews
  for select using (public.is_staff());

drop policy if exists "staff update reviews" on public.reviews;
create policy "staff update reviews" on public.reviews
  for update using (public.is_staff());

-- Vista pública para el storefront: SÓLO las aprobadas y SÓLO columnas
-- seguras. Nunca expone customer_email ni token (por eso es una vista y no
-- una policy sobre la tabla: RLS filtra filas, no columnas).
create or replace view public.public_reviews as
  select id, customer_name, rating, comment, submitted_at
  from public.reviews
  where status = 'approved';

grant select on public.public_reviews to anon;
grant select on public.public_reviews to authenticated;
