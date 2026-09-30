@echo off
setlocal
where pyw >nul 2>nul
if %errorlevel%==0 (
  pyw -3 "%~dp0HyperXBatteryTray.py"
) else (
  pythonw "%~dp0HyperXBatteryTray.py"
)
