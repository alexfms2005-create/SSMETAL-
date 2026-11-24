@echo off
chcp 65001 > nul
title SSMF - SS Metal Foundry (MES / SCADA)
color 0C

echo ========================================================
echo    SSMF - SS METAL FOUNDRY (Sistema MES / SCADA)
echo    Iniciando Servidor Backend MySQL y Frontend...
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

:: 2. Verificar si node_modules existe; si no, instalar dependencias automáticamente
if not exist "node_modules\" (
    echo [AVISO] Dependencias no encontradas.
    echo Instalando paquetes automáticamente (npm install)...
    echo.
    call npm install
    echo.
)

:: 3. Abrir el navegador en http://localhost:3000 automáticamente
start "" cmd /c "timeout /t 3 >nul && start http://localhost:3000"

:: 4. Iniciar el sistema (Backend Express + MySQL y Frontend Vite)
echo [OK] Sistema arrancando en: http://localhost:3000
echo Presiona Ctrl + C en esta ventana cuando desees detener el servidor.
echo.
call npm run dev
pause
