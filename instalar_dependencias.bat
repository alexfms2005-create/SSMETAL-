@echo off
chcp 65001 > nul
title SSMF - Instalador de Dependencias
color 0C

echo ========================================================
echo    SSMF - SS METAL FOUNDRY
echo    Instalador Automático de Dependencias
echo ========================================================
echo.

:: 1. Verificar si Node.js está instalado
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js no está instalado en este equipo.
    echo Por favor descarga e instala Node.js desde: https://nodejs.org/
    echo.
    pause
    exit /b
)

echo [OK] Node.js detectado en el sistema:
node -v
echo.

:: 2. Instalar paquetes de npm
echo [1/2] Instalando paquetes y librerías necesarias...
echo Esto puede tomar unos segundos, por favor espera...
echo.
call npm install
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Hubo un problema al instalar las dependencias con npm.
    pause
    exit /b
)

echo.
echo [2/2] Verificando compilación de archivos...
call npm run build
if %errorlevel% neq 0 (
    echo.
    echo [ADVERTENCIA] La compilación tuvo una alerta, pero las dependencias están listas.
)

echo.
echo ========================================================
echo    ¡TODAS LAS DEPENDENCIAS SE INSTALARON CON ÉXITO!
echo ========================================================
echo.
echo Ahora puedes arrancar el sistema simplemente con:
echo    - Doble clic en "iniciar_sistema.bat"
echo    - O ejecutando en la terminal: npm run dev
echo.
pause
