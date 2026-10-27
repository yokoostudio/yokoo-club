// Ventana de doble estrella del CyberMonday 2026.
//
// Durante estos días, cada compra web suma DOS estrellas en vez de una. Fuera
// de la ventana todo funciona como siempre: no hay que desactivar nada después,
// se apaga solo.
//
// Las fechas son hora de Argentina (UTC-3, el país no tiene horario de verano),
// expresadas acá en UTC para no depender de la zona horaria del servidor:
//   viernes 30/10/2026 20:00 ART = 2026-10-30T23:00:00Z  (abre el Club)
//   miércoles 4/11/2026 23:59:59 ART = 2026-11-05T02:59:59Z
//
// Para cambiar el período, tocar sólo estas dos constantes y volver a
// desplegar las dos funciones que importan este archivo
// (tn-webhook-order-paid y tn-backfill-stamps).

export const CYBER_DESDE = Date.parse("2026-10-30T23:00:00.000Z");
export const CYBER_HASTA = Date.parse("2026-11-05T02:59:59.999Z");

// Origen con el que se registra la estrella extra. Es un valor propio del enum
// stamp_source (ver supabase/sql/parte-16-doble-estrella-cyber.sql): como
// stamp_events tiene UNIQUE(source, order_id), usar un origen distinto es lo
// que permite guardar DOS estrellas del mismo pedido sin romper esa guarda, y
// además deja claro en el historial de dónde salió cada una.
export const CYBER_SOURCE = "cyber_bonus";

// ¿Esta compra cae dentro de la ventana? Recibe la fecha del PEDIDO, no la de
// hoy: así un pedido del Cyber sigue valiendo doble aunque la estrella se
// registre más tarde (por ejemplo cuando alguien que compró sin cuenta se
// registra después y entra el backfill).
export function esCompraDelCyber(fechaDelPedido: string | null | undefined): boolean {
  if (!fechaDelPedido) return false;
  const ms = Date.parse(fechaDelPedido);
  if (Number.isNaN(ms)) return false;
  return ms >= CYBER_DESDE && ms <= CYBER_HASTA;
}
