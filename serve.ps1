param([int]$Port = 8888)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Sirviendo $root en http://localhost:$Port/"

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".js"   = "application/javascript"
  ".css"  = "text/css"
  ".png"  = "image/png"
  ".svg"  = "image/svg+xml"
  ".json" = "application/json"
}

$logPath = Join-Path $root "requests.log"

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $req = $context.Request
  $res = $context.Response
  try {
    $line = "{0}  {1}" -f (Get-Date -Format "s"), $req.Url.PathAndQuery
    Add-Content -Path $logPath -Value $line
    $path = $req.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    $filePath = Join-Path $root ($path.TrimStart("/"))
    if (Test-Path $filePath -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($filePath)
      $contentType = $mime[$ext]
      if (-not $contentType) { $contentType = "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($filePath)
      $res.ContentType = $contentType
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $notFound = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
      $res.OutputStream.Write($notFound, 0, $notFound.Length)
    }
  } catch {
    $res.StatusCode = 500
  } finally {
    $res.OutputStream.Close()
  }
}
