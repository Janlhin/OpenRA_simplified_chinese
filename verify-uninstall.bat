@echo off
chcp 65001 >nul
setlocal
title OpenRA Simplified Chinese Patch - Verify Uninstall
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Verify %*
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo [OK] Patch fully uninstalled) else (echo [FAIL] Patch files still present - see report above)
echo.
echo Press any key to close this window . . .
pause >nul
endlocal
