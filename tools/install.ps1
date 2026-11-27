. "$PSScriptRoot/runtime.ps1"
if (-not (Test-Path -LiteralPath '.env')) { Copy-Item -LiteralPath '.env.example' -Destination '.env' }
$composerCommand = Get-Command composer -ErrorAction SilentlyContinue
if (-not $composerCommand) { throw 'Instala Composer antes de continuar.' }
& $composerCommand.Source install --prefer-dist --no-interaction
if ($LASTEXITCODE -ne 0) { throw 'Fallo Composer.' }
$envText = Get-Content -LiteralPath '.env' -Raw
if ($envText -match '(?m)^APP_KEY=\s*$') { Invoke-ProjectPhp artisan key:generate --force }
Invoke-ProjectPhp tools/setup-database.php
Invoke-ProjectPhp artisan migrate --force
Invoke-ProjectPhp artisan db:seed --force
Invoke-ProjectPhp artisan foundry:import-backlog
Invoke-ProjectPhp tools/bootstrap-admin.php
Invoke-ProjectPhp artisan view:cache
Write-Host 'Instalacion terminada. Ejecuta iniciar_sistema.bat. MySQL debe permanecer iniciado.' -ForegroundColor Green
