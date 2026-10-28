# Dispara una campaña de mail a la lista del Club.
#
#   .\enviar.ps1 -Archivo primavera-aviso.json -DryRun      <- cuenta, no manda
#   .\enviar.ps1 -Archivo primavera-aviso.json -Prueba      <- sólo a tus casillas
#   .\enviar.ps1 -Archivo primavera-aviso.json              <- envío real
#
# El contenido del mail vive en el .json, no acá: para la próxima campaña
# copiás el json, lo editás y listo.
#
# El CRON_SECRET no se escribe nunca en este archivo (el repo es PÚBLICO).
# La primera vez te lo pide y lo guarda en ..\.secrets\ (que está en .gitignore).

param(
  [Parameter(Mandatory = $true)][string]$Archivo,
  [switch]$DryRun,
  [switch]$Prueba
)

$ErrorActionPreference = "Stop"

$raiz = Split-Path -Parent $PSScriptRoot
$rutaSecreto = Join-Path $raiz ".secrets\campaign-secret.txt"
$FUNCION = "https://givnsohzgsugvrfuftcm.supabase.co/functions/v1/campaign-send"

# Casillas que reciben la prueba con -Prueba. Cambialas si querés sumar a alguien.
$CASILLAS_DE_PRUEBA = @("jcdibastiano@gmail.com", "yokoo.std@gmail.com")

# --- contenido -------------------------------------------------------------
$rutaJson = if (Test-Path $Archivo) { $Archivo } else { Join-Path $PSScriptRoot $Archivo }
if (-not (Test-Path $rutaJson)) { throw "No encuentro el archivo de campaña: $Archivo" }

$campania = Get-Content -Raw -Encoding UTF8 $rutaJson | ConvertFrom-Json

if ($DryRun) { $campania | Add-Member -NotePropertyName dryRun -NotePropertyValue $true -Force }
if ($Prueba) { $campania | Add-Member -NotePropertyName testEmails -NotePropertyValue $CASILLAS_DE_PRUEBA -Force }

# --- secreto ---------------------------------------------------------------
if (-not (Test-Path $rutaSecreto)) {
  throw "Falta el archivo .secrets\campaign-secret.txt. Sin eso la función no autoriza el envío."
}
$secreto = (Get-Content -Raw $rutaSecreto).Trim()

# --- confirmación en envío real -------------------------------------------
if (-not $DryRun -and -not $Prueba) {
  Write-Host ""
  Write-Host "  ENVIO REAL A TODA LA LISTA DEL CLUB" -ForegroundColor Red
  Write-Host "  Campaña: $($campania.slug)"
  Write-Host "  Asunto:  $($campania.subject)"
  Write-Host ""
  $ok = Read-Host "Escribí SI para mandar"
  if ($ok -ne "SI") { Write-Host "Cancelado." -ForegroundColor Yellow; exit 0 }
}

# --- envío -----------------------------------------------------------------
$json = $campania | ConvertTo-Json -Depth 10 -Compress
$bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

$modo = if ($DryRun) { "SIMULACRO" } elseif ($Prueba) { "PRUEBA" } else { "REAL" }
Write-Host "Enviando ($modo)..." -ForegroundColor Cyan

try {
  $r = Invoke-RestMethod -Uri $FUNCION -Method Post -Body $bytes -Headers @{
    "Content-Type"         = "application/json; charset=utf-8"
    "x-yokoo-cron-secret"  = $secreto
  }
  Write-Host ""
  $r | ConvertTo-Json -Depth 10
  Write-Host ""
  if ($r.ok -and -not $DryRun) { Write-Host "Listo." -ForegroundColor Green }
} catch {
  Write-Host ""
  Write-Host "FALLÓ: $($_.Exception.Message)" -ForegroundColor Red
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message -ForegroundColor Red }
  exit 1
}
