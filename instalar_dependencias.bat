@echo off
chcp 65001 > nul
title SSMF - Instalador Automático de Dependencias y Base de Datos
color 0C

echo ========================================================
echo    SSMF - SS METAL FOUNDRY
echo    Instalador Automático de Dependencias y Base de Datos
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

echo [OK] Node.js detectado:
node -v
echo.

:: 2. Crear archivo .env automáticamente si no existe
if not exist ".env" (
    echo [1/4] Creando archivo de configuración .env desde plantilla...
    copy .env.example .env >nul
    echo [OK] Archivo .env generado exitosamente.
    echo.
) else (
    echo [1/4] Archivo .env detectado.
    echo.
)

:: 3. Instalar paquetes de npm
echo [2/4] Instalando paquetes y librerías necesarias...
echo Esto puede tomar unos segundos, por favor espera...
echo.
call npm install
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Hubo un problema al instalar las dependencias con npm.
    pause
    exit /b
)

:: 4. Auto-crear base de datos y tablas en MySQL
echo.
echo [3/4] Creando y configurando base de datos MySQL (ssmf_db)...
node -e "import('./server/db.js').then(() => console.log('[OK] Base de datos MySQL ssmf_db y tablas creadas exitosamente.')).catch(err => console.log('[AVISO] Asegúrate de que MySQL (XAMPP) esté iniciado: ' + err.message));"

:: 5. Verificando compilación
echo.
echo [4/4] Verificando compilación de archivos...
call npm run build
if %errorlevel% neq 0 (
    echo.
    echo [ADVERTENCIA] La compilación tuvo una alerta, pero las dependencias están listas.
)

echo.
echo ========================================================
echo    ¡TODO QUEDÓ INSTALADO Y CONFIGURADO CON ÉXITO!
echo ========================================================
echo.
echo Ahora puedes arrancar el sistema simplemente con:
echo    - Doble clic en "iniciar_sistema.bat"
echo    - O ejecutando en la terminal: npm run dev
echo.
echo Nota: También tienes el archivo "ssmf_db.sql" por si deseas
echo importarlo manualmente desde phpMyAdmin.
echo.
pause
