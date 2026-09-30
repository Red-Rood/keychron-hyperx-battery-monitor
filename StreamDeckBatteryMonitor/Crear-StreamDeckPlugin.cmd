@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Se necesita instalar Node.js 24 o posterior para compilar el plugin.
  pause
  exit /b 1
)

npm install
if errorlevel 1 goto :error
npm run build
if errorlevel 1 goto :error
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Generar-IconoPlugin.ps1"
if errorlevel 1 goto :error
npm run install:runtime
if errorlevel 1 goto :error
npm run pack -- --no-update-check
if errorlevel 1 goto :error

echo.
echo Plugin listo. Abre el archivo .streamDeckPlugin generado para instalarlo.
pause
exit /b 0

:error
echo.
echo No se pudo crear el plugin. Revisa el error anterior.
pause
exit /b 1
