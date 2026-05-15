# CTCC Installer for Windows (compatible with PowerShell 4.0+)
# Windows 8.1 users: download and right-click -> "Run with PowerShell"
# Windows 10/11 users: Invoke-WebRequest -Uri https://abc6712.netlify.app/install.ps1 | iex

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

    Write-Host "Downloading..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $pyUrl -OutFile $pyInstaller -UseBasicParsing

    Write-Host "Installing Python silently..." -ForegroundColor Cyan
    Start-Process -FilePath $pyInstaller -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_launcher=0" -Wait
    Remove-Item $pyInstaller -ErrorAction SilentlyContinue

    # Refresh PATH in this session
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
        Write-Host "Python install failed. Please install manually from:" -ForegroundColor Red
        Write-Host "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe" -ForegroundColor Red
        Write-Host "Make sure to check 'Add Python to PATH' during install." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Host "Python installed!" -ForegroundColor Green
} else {
    Write-Host "Python found." -ForegroundColor Green
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

# Write the .bat wrapper
$batContent = "@echo off`r`n$python `"$scriptPath`" %*"
Set-Content -Path $batPath -Value $batContent -Encoding ASCII

# Add to user PATH if not already there
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
Write-Host "  ctcc run          - open a room"
Write-Host "  ctcc join <IP>    - join a room"
Write-Host ""
Read-Host "Press Enter to exit"
