@echo off
powershell -NoLogo -ExecutionPolicy Bypass -File "%~dp0upgrade_ps.ps1"
echo.
echo ===========================================
echo Finished running upgrade_ps.ps1
echo Press any key to close this window...
echo ===========================================
pause >nul
