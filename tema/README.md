# Código propio del tema de Tiendanube

Archivos que escribimos nosotros y viven en el tema (Morelia) de
`yokoo.mitiendanube.com`. El resto del tema es de Tiendanube y no se versiona
acá (`tema-backup/` está en .gitignore).

## Cómo se trabaja

El tema se edita por **FTP con TLS explícito**. Con curl:

    curl --ssl-reqd -u "USUARIO:CLAVE" "ftp://ftp.tiendanube.com/snipplets/archivo.tpl"

Sin `--ssl-reqd` el servidor responde `534 TLS required` y parece un problema
de credenciales, pero no lo es.

Antes de subir cualquier cosa: bajar una copia fresca del archivo, comparar
contra la copia local para confirmar que nadie lo tocó en el medio, editar,
subir, y volver a bajarlo para verificar que quedó igual.

Verificar SIEMPRE con `?preview=true`, que saltea el cache de Tiendanube:

    https://www.yokoo.com.ar/the-third-place?preview=true

La URL pública sin ese parámetro puede servir una versión vieja por mucho tiempo.

## Archivos

- `snipplets/yk-stock-badge.tpl` — cartel de últimas unidades en las tarjetas
  de producto. Se incluye una sola vez desde `layouts/layout.tpl`, justo antes
  de `</body>`. Para desactivarlo, sacar ese include.
