@echo off
setlocal enabledelayedexpansion
title CTCC Installer

echo.
echo  ========================================
echo   CTCC - Computer to Computer Communication
echo   Installer
echo  ========================================
echo.

:: ── Check if we already upgraded PowerShell (set by us after WMF install) ──
reg query "HKCU\Software\CTCC" /v WMFInstalled >nul 2>&1
if %errorlevel% == 0 goto :after_wmf

:: ── Check PowerShell version ─────────────────────────────────
for /f "tokens=*" %%V in ('powershell -command "$PSVersionTable.PSVersion.Major" 2^>nul') do set PS_VER=%%V

if "%PS_VER%" == "" set PS_VER=0
if %PS_VER% GEQ 5 (
    echo [OK] PowerShell 5+ found. Skipping WMF install.
    goto :after_wmf
)

:: ── Download and install WMF 5.1 ─────────────────────────────
echo [..] PowerShell is outdated ^(version %PS_VER%^).
echo [..] Downloading Windows Management Framework 5.1...
echo      This will require a restart. Install will continue automatically.
echo.

set WMF_URL=https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu
set WMF_INSTALLER=%TEMP%\wmf51.msu

:: Try bitsadmin
bitsadmin /transfer "WMFDownload" /download /priority normal "%WMF_URL%" "%WMF_INSTALLER%" >nul 2>&1

if not exist "%WMF_INSTALLER%" (
    certutil -urlcache -split -f "%WMF_URL%" "%WMF_INSTALLER%" >nul 2>&1
)

if not exist "%WMF_INSTALLER%" (
    echo [ERR] Could not download WMF 5.1. Check your internet connection.
    pause
    exit /b 1
)

:: ── Register this bat to run again after restart ──────────────
reg add "HKCU\Software\CTCC" /v WMFInstalled /t REG_SZ /d "1" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "CTCCInstaller" /t REG_SZ /d "\"%~f0\"" /f >nul
echo [OK] Registered CTCC installer to continue after restart.

:: ── Install WMF silently and reboot ──────────────────────────
echo [..] Installing WMF 5.1 and restarting in 10 seconds...
echo      The install will continue automatically after restart.
echo.
wusa.exe "%WMF_INSTALLER%" /quiet /norestart
del "%WMF_INSTALLER%" >nul 2>&1
shutdown /r /t 10 /c "CTCC Installer: Restarting to finish PowerShell upgrade..."
exit /b 0

:: ── After WMF / restart — now do the real install ────────────
:after_wmf

:: Clean up our registry flag
reg delete "HKCU\Software\CTCC" /v WMFInstalled /f >nul 2>&1

echo [..] Checking for Python...

:: Check Python
powershell -command "python --version" >nul 2>&1
if %errorlevel% == 0 (
    set PYTHON=python
    goto :install_ctcc
)
powershell -command "python3 --version" >nul 2>&1
if %errorlevel% == 0 (
    set PYTHON=python3
    goto :install_ctcc
)

:: ── Auto install Python via irm now that PS5 is available ─────
echo [..] Python not found. Installing via PowerShell...
powershell -command "irm https://abc6712.netlify.app/install.ps1 | iex"
if %errorlevel% neq 0 (
    echo [ERR] Python install failed. Please install from https://python.org
    pause
    exit /b 1
)
set PYTHON=python

:: ── Install ctcc ──────────────────────────────────────────────
:install_ctcc
echo.
echo [..] Downloading ctcc...

set INSTALL_DIR=%USERPROFILE%\.ctcc
set SCRIPT_PATH=%INSTALL_DIR%\ctcc.py
set BAT_PATH=%INSTALL_DIR%\ctcc.bat

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

powershell -command "irm https://abc6712.netlify.app/ctcc -OutFile '%SCRIPT_PATH%'"

if not exist "%SCRIPT_PATH%" (
    echo [ERR] Could not download ctcc. Check your internet connection.
    pause
    exit /b 1
)

:: Write the .bat wrapper
echo @echo off > "%BAT_PATH%"
echo %PYTHON% "%SCRIPT_PATH%" %%* >> "%BAT_PATH%"

:: Add to user PATH
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "CURPATH=%%B"
echo !CURPATH! | find /i "%INSTALL_DIR%" >nul 2>&1
if %errorlevel% neq 0 (
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!CURPATH!;%INSTALL_DIR%" /f >nul
    echo [OK] Added ctcc to PATH.
) else (
    echo [OK] PATH already set.
)

echo.
echo  ========================================
echo   Done! Close and reopen your terminal.
echo  ========================================
echo.
echo   ctcc run          - open a room
echo   ctcc join ^<IP^>    - join a room
echo.
pause
