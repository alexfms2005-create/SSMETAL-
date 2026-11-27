$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $projectRoot
$phpCommand = Get-Command php -ErrorAction SilentlyContinue
if (-not $phpCommand) { throw 'PHP 8.3+ no encontrado en PATH.' }
$phpExecutable = $phpCommand.Source
$runtimeInfo = (& $phpExecutable tools/runtime-info.php) | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'No fue posible ejecutar PHP.' }
if ($runtimeInfo.drivers -notcontains 'mysql') {
    $extensionDir = $runtimeInfo.extension_dir
    $mysqlExtension = Join-Path $extensionDir 'php_pdo_mysql.dll'
    if (-not (Test-Path -LiteralPath $mysqlExtension)) { throw 'Falta la extension pdo_mysql de PHP.' }
    $localIni = Join-Path $projectRoot 'storage/app/php-conf'
    New-Item -ItemType Directory -Force -Path $localIni | Out-Null
    $extensionLine = 'extension="' + $mysqlExtension.Replace('\','/') + '"'
    [IO.File]::WriteAllText((Join-Path $localIni 'mysql.ini'), $extensionLine, [Text.UTF8Encoding]::new($false))
    $env:PHP_INI_SCAN_DIR = $localIni
}
function Invoke-ProjectPhp {
    & $phpExecutable @args
    if ($LASTEXITCODE -ne 0) { throw "PHP termino con codigo $LASTEXITCODE." }
}
