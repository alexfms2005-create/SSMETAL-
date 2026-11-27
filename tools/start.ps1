. "$PSScriptRoot/runtime.ps1"
if (-not (Test-Path -LiteralPath 'vendor/autoload.php')) { throw 'Ejecuta instalar_dependencias.bat primero.' }
if (-not (Test-Path -LiteralPath '.env')) { throw 'Falta .env. Ejecuta instalar_dependencias.bat.' }
Invoke-ProjectPhp artisan migrate:status
Write-Host 'Sistema en http://127.0.0.1:8002  Ctrl+C para detener.' -ForegroundColor Green
Invoke-ProjectPhp artisan serve --host=127.0.0.1 --port=8002 --no-reload
