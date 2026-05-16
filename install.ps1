# CTCC Installer for Windows (with ngrok)
# Windows 8/8.1: download and right-click -> "Run with PowerShell"
# Windows 10/11: irm https://abc6712.netlify.app/install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "CTCC - Computer to Computer Communication" -ForegroundColor Yellow
Write-Host "Installer" -ForegroundColor Yellow
Write-Host ""

# ── Check / Auto-install Python ───────────────────────────────
$python = $null
foreach ($cmd in @("python", "python3")) {
    try {
        $ver = & $cmd --version 2>&1
        if ($ver -match "Python 3") {
            $python = $cmd
            break
        }
    } catch {}
}

if (-not $python) {
    Write-Host "Python not found. Downloading Python 3.8.10..." -ForegroundColor Yellow
    Write-Host "(3.8.10 is the last version that supports Windows 8/8.1)" -ForegroundColor Gray

    $pyInstaller = "$env:TEMP\python_installer.exe"
    $pyUrl = "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe"

    Write-Host "Downloading Python..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $pyUrl -OutFile $pyInstaller -UseBasicParsing

    Write-Host "Installing Python silently..." -ForegroundColor Cyan
    Start-Process -FilePath $pyInstaller -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_launcher=0" -Wait
    Remove-Item $pyInstaller -ErrorAction SilentlyContinue

    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("PATH", "User") + ";" +
                "$env:LOCALAPPDATA\Programs\Python\Python38;" +
                "$env:LOCALAPPDATA\Programs\Python\Python38\Scripts"

    foreach ($cmd in @("python", "python3")) {
        try {
            $ver = & $cmd --version 2>&1
            if ($ver -match "Python 3") {
                $python = $cmd
                break
            }
        } catch {}
    }

    if (-not $python) {
        Write-Host ""
        Write-Host "Python install failed." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Host "Python installed!" -ForegroundColor Green
} else {
    Write-Host "Python found." -ForegroundColor Green
}

# ── Check / Auto-install ngrok ────────────────────────────────
$ngrok = $null
try {
    $ver = ngrok --version 2>&1
    if ($ver -match "ngrok") {
        $ngrok = "ngrok"
    }
} catch {}

if (-not $ngrok) {
    Write-Host "ngrok not found. Downloading ngrok..." -ForegroundColor Yellow

    $ngrokZip = "$env:TEMP\ngrok.zip"
    $ngrokUrl = "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip"

    Invoke-WebRequest -Uri $ngrokUrl -OutFile $ngrokZip -UseBasicParsing

    Write-Host "Extracting ngrok..." -ForegroundColor Cyan
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ngrokZip, "$env:TEMP\ngrok_extract")

    $ngrokDir = "$env:USERPROFILE\.ctcc\bin"
    if (-not (Test-Path $ngrokDir)) {
        New-Item -ItemType Directory -Path $ngrokDir | Out-Null
    }

    Move-Item -Path "$env:TEMP\ngrok_extract\ngrok.exe" -Destination "$ngrokDir\ngrok.exe" -Force
    Remove-Item "$ngrokZip" -Force
    Remove-Item "$env:TEMP\ngrok_extract" -Recurse -Force

    # Add ngrok to PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$ngrokDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$userPath;$ngrokDir", "User")
    }

    $env:PATH = "$env:PATH;$ngrokDir"
    Write-Host "ngrok installed!" -ForegroundColor Green
} else {
    Write-Host "ngrok found." -ForegroundColor Green
}

# ── Install ctcc ──────────────────────────────────────────────
$installDir = "$env:USERPROFILE\.ctcc"
$scriptPath = "$installDir\ctcc.py"
$batPath    = "$installDir\ctcc.bat"

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

Write-Host "Downloading ctcc..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://abc6712.netlify.app/ctcc" -OutFile $scriptPath -UseBasicParsing

$batContent = "@echo off`r`n$python `"$scriptPath`" %*"
Set-Content -Path $batPath -Value $batContent -Encoding ASCII

$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$userPath;$installDir", "User")
    Write-Host "Added ctcc to PATH." -ForegroundColor Green
} else {
    Write-Host "PATH already set." -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Done! Close and reopen your terminal." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  ctcc server          - start the relay server"
Write-Host "  ctcc connect <addr>  - connect via ngrok"
Write-Host "  ctcc join <addr>     - connect locally"
Write-Host ""
Read-Host "Press Enter to exit"
