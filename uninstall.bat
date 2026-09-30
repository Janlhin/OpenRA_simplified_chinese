@echo off
chcp 65001 >nul
setlocal
title OpenRA Simplified Chinese Patch - Restore
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Uninstall %*
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" echo [FAILED] exit code %RC%
echo Press any key to close this window . . .
pause >nul
endlocal
