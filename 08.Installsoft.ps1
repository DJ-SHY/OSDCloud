# ==============================================================================
# File: 08.InstallSoft.ps1
# Path: C:\Windows\Setup\Scripts\08.Installsoft.ps1
# ==============================================================================
Write-Host "[OSDCloud] Installing Local Big Software Packages..." -ForegroundColor Yellow

$AppsDir = "$PSScriptRoot\Apps"

if (-not (Test-Path $AppsDir)) {
    Write-Host " [!] Local Apps directory not found ($AppsDir). Skipping..." -ForegroundColor Red
    exit 0
}

# ------------------------------------------------------------------------------
# 1. Microsoft Office (經 ODT 離線安裝)
# ------------------------------------------------------------------------------
$OfficeSetup = Join-Path $AppsDir "Office\setup.exe"
$OfficeConfig = Join-Path $AppsDir "Office\configuration.xml"

if ((Test-Path $OfficeSetup) -and (Test-Path $OfficeConfig)) {
    Write-Host "  [+] Installing Microsoft Office (ODT Offline)..." -ForegroundColor Gray
    Start-Process -FilePath $OfficeSetup -ArgumentList "/configure `"$OfficeConfig`"" -Wait -NoNewWindow
    Write-Host "  [OK] Office installed successfully!" -ForegroundColor Green
} else {
    Write-Host "  [-] Office setup files not found, skipping..." -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# 2. Adobe Acrobat Reader / DC (MSI 或 EXE 靜默)
# ------------------------------------------------------------------------------
$AcrobatMsi = Join-Path $AppsDir "Acrobat\AcroRead.msi"
$AcrobatExe = Join-Path $AppsDir "Acrobat\AcroRdrDC.exe"

if (Test-Path $AcrobatMsi) {
    Write-Host "  [+] Installing Adobe Acrobat (MSI)..." -ForegroundColor Gray
    Start-Process msiexec.exe -ArgumentList "/i `"$AcrobatMsi`" /qn /norestart EULA_ACCEPT=YES" -Wait -NoNewWindow
    Write-Host "  [OK] Adobe Acrobat installed successfully!" -ForegroundColor Green
} elseif (Test-Path $AcrobatExe) {
    Write-Host "  [+] Installing Adobe Acrobat (EXE)..." -ForegroundColor Gray
    Start-Process -FilePath $AcrobatExe -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait -NoNewWindow
    Write-Host "  [OK] Adobe Acrobat installed successfully!" -ForegroundColor Green
} else {
    Write-Host "  [-] Adobe Acrobat installer not found, skipping..." -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# 3. PotPlayer (64-bit EXE 靜默)
# ------------------------------------------------------------------------------
$PotPlayerInstaller = Get-ChildItem -Path "$AppsDir\PotPlayer" -Filter "*PotPlayer*Setup*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($PotPlayerInstaller) {
    Write-Host "  [+] Installing PotPlayer..." -ForegroundColor Gray
    Start-Process -FilePath $PotPlayerInstaller.FullName -ArgumentList "/S" -Wait -NoNewWindow
    Write-Host "  [OK] PotPlayer installed successfully!" -ForegroundColor Green
} else {
    Write-Host "  [-] PotPlayer installer not found, skipping..." -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# 4. K-Lite Codec Pack Mega (Inno Setup 靜默)
# ------------------------------------------------------------------------------
$KLiteInstaller = Get-ChildItem -Path "$AppsDir\KLite" -Filter "*K-Lite*Mega*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($KLiteInstaller) {
    Write-Host "  [+] Installing K-Lite Codec Pack Mega..." -ForegroundColor Gray
    Start-Process -FilePath $KLiteInstaller.FullName -ArgumentList "/verysilent /norestart" -Wait -NoNewWindow
    Write-Host "  [OK] K-Lite Codec Pack Mega installed successfully!" -ForegroundColor Green
} else {
    Write-Host "  [-] K-Lite Codec Pack Mega installer not found, skipping..." -ForegroundColor Yellow
}

Write-Host " -> All software installation tasks completed!" -ForegroundColor Green
