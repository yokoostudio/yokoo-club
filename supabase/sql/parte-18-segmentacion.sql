-- Parte 18: segmentación de campañas (26/10/2026)
--
-- Hasta ahora una campaña iba a TODA la lista. Para el Cyber hacen falta dos
-- recortes:
--   - el refuerzo del domingo, que no debe ir a quien ya compró el sábado
--     (mandarle "¿todavía no compraste?" a alguien que compró ayer es la
--     forma más rápida de ganarse una baja, y la lista viene con cero);
--   - el mail del 7/11, que va SÓLO a quien compró durante el Cyber.
--
-- Quién compró se sabe por stamp_events: cada compra web deja una estrella
-- con su fecha. No hace falta ningún dato nuevo.

alter table public.campaigns
  add column if not exists audiencia text not null default 'todos',
  add column if not exists audiencia_desde timestamptz,
  add column if not exists audiencia_hasta timestamptz;

alter table public.campaigns drop constraint if exists campaigns_audiencia_check;
alter table public.campaigns add constraint campaigns_audiencia_check
  check (audiencia in ('todos', 'compraron', 'no_compraron'));

comment on column public.campaigns.audiencia is
  'todos | compraron | no_compraron. Los dos ultimos miran las compras web entre audiencia_desde y audiencia_hasta.';
