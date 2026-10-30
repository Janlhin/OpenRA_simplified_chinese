@echo off
rem ===========================================================================
rem  OpenRA Simplified Chinese Patch - single entry point
rem
rem  This file is intentionally ASCII-only: a .bat holding Chinese text breaks
rem  under legacy code pages (mojibake), so every Chinese message lives in
rem  install.ps1 (UTF-8 with BOM) and in the readme txt next to this script.
rem
rem  Double-click  -> Chinese menu (install / uninstall / verify / dry-run)
rem  With arguments -> passed straight to install.ps1, e.g.
rem      setup.cmd -Target "D:\Games\OpenRA" -Yes
rem      setup.cmd -Uninstall
rem ===========================================================================
setlocal EnableExtensions
title OpenRA Simplified Chinese Patch
cd /d "%~dp0"

set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS%" set "PS=powershell.exe"

if "%~1"=="" goto MENU

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0bin\install.ps1" %*
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto FAILED
exit /b 0

:MENU
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0bin\install.ps1" -Menu
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto FAILED
exit /b 0

:FAILED
echo.
echo  [!] Installer stopped with exit code %RC%.
echo      If Windows says "running scripts is disabled on this system",
echo      group policy is blocking PowerShell on this PC. Open the readme
echo      txt next to this script and follow the manual install steps.
echo.
pause
exit /b %RC%
