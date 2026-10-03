@echo off
setlocal
where pyw >nul 2>nul
if %errorlevel%==0 (
  start "" /b pyw -3 "%~dp0HyperXBatteryTray.py"
) else (
  start "" /b pythonw "%~dp0HyperXBatteryTray.py"
)
exit /b 0
