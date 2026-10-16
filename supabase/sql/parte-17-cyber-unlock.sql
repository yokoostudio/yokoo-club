-- Parte 17: registro desde la tienda para el Cyber (16/10/2026)
--
-- La barra del storefront manda el mail a la Edge Function cyber-unlock, que
-- crea la cuenta del Club y devuelve el acceso en el momento.
--
-- Esa función queda ABIERTA a internet (la llama cualquier visitante, sin
-- sesión) y manda mails. Sin un freno, alguien puede dispararla en loop con
-- direcciones inventadas: nos quema la cuota de Resend y, peor, nos arruina la
-- reputación del dominio mandando correo no solicitado. Esta tabla es el
-- registro contra el que se cuentan los intentos.
--
-- Se guarda el hash de la IP, no la IP: alcanza para contar y limitar, y no
-- deja un dato personal más del que ya tenemos.

create table if not exists public.gate_requests (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  ip_hash text,
  created_at timestamptz not null default now()
);

create index if not exists gate_requests_created_idx on public.gate_requests (created_at desc);
create index if not exists gate_requests_email_idx on public.gate_requests (email, created_at desc);
create index if not exists gate_requests_ip_idx on public.gate_requests (ip_hash, created_at desc);

alter table public.gate_requests enable row level security;

-- Nadie lo lee con la clave pública; las Edge Functions usan service_role,
-- que ignora RLS. Sólo el staff puede mirarlo desde el panel.
drop policy if exists "staff read gate_requests" on public.gate_requests;
create policy "staff read gate_requests"
  on public.gate_requests for select
  using (public.is_staff());
