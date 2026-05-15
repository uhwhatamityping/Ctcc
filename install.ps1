# CTCC Installer for Windows
# Run with: irm https://abc6712.netlify.app/install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "CTCC - Computer to Computer Communication" -ForegroundColor Yellow
Write-Host "Installer" -ForegroundColor Yellow
Write-Host ""

# Check python3
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Python is required but not found." -ForegroundColor Red
    Write-Host "Download it from https://python.org" -ForegroundColor Red
    exit 1
}

$installDir = "$env:USERPROFILE\ctcc"
$scriptPath = "$installDir\ctcc.py"
$batPath    = "$installDir\ctcc.bat"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "Downloading ctcc..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://abc6712.netlify.app/ctcc" -OutFile $scriptPath

# Create a .bat wrapper so 'ctcc' works from anywhere
@"
@echo off
python "$scriptPath" %*
"@ | Set-Content $batPath

# Add to PATH if not already there
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installDir", "User")
    Write-Host "Added $installDir to PATH." -ForegroundColor Green
    Write-Host "Restart your terminal for PATH to take effect." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done! You can now run:" -ForegroundColor Green
Write-Host ""
Write-Host "  ctcc run           - open a room"
Write-Host "  ctcc join <IP>     - join a room"
Write-Host ""
