-- Parte 19: códigos de Navidad post-Cyber (26/10/2026)
--
-- Una fila por persona a la que ya se le mandó su código. Es la guarda
-- anti-duplicado: si la función se vuelve a correr (porque falló a mitad de
-- camino, o porque alguien la dispara de nuevo), sólo le manda a quien falta.
-- Importa especialmente porque la corrida del 7/11 es automática y Juan está
-- de viaje: nadie va a estar mirando.

create table if not exists public.navidad_codigos (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null unique,
  email text not null,
  code text not null,
  sent_at timestamptz not null default now()
);

alter table public.navidad_codigos enable row level security;

drop policy if exists "staff read navidad_codigos" on public.navidad_codigos;
create policy "staff read navidad_codigos"
  on public.navidad_codigos for select
  using (public.is_staff());
