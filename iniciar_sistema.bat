@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Steel Fused Solutions and SS Metal Foundry - Laravel
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\start.ps1"
if errorlevel 1 pause
