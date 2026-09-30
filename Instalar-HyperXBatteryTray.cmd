@echo off
setlocal
where py >nul 2>nul
if %errorlevel%==0 (
  set "PYTHON=py -3"
) else (
  where python >nul 2>nul
  if errorlevel 1 (
    echo No se encontro Python. Instala Python 3 desde https://www.python.org/downloads/windows/
    pause
    exit /b 1
  )
  set "PYTHON=python"
)

echo Instalando dependencias del monitor HyperX...
%PYTHON% -m pip install --user -r "%~dp0requirements-hyperx.txt"
if errorlevel 1 (
  echo No se pudieron instalar las dependencias.
  pause
  exit /b 1
)

echo Dependencias instaladas. Puedes ejecutar Iniciar-HyperXBatteryTray.cmd.
pause
