@echo off
chcp 65001 >nul
cd /d "%~dp0"
title SSMF y SFS - Instalacion Laravel
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\install.ps1"
pause
