# ==============================================================================
# File: 08.InstallSoft.ps1
# Path: C:\Windows\Setup\Scripts\08.Installsoft.ps1
# ==============================================================================
Write-Host "[OSDCloud] Installing Software Packages..." -ForegroundColor Yellow

$AppsDir = "$PSScriptRoot\Apps"

if (-not (Test-Path $AppsDir)) {
    Write-Host " [!] Local Apps directory not found ($AppsDir). Skipping..." -ForegroundColor Red
    exit 0
}

# ------------------------------------------------------------------------------
# 0. Microsoft VC++ AIO
# ------------------------------------------------------------------------------
Write-Host "  [+] Fetching & Installing Latest VC++ AIO directly from GitHub..." -ForegroundColor Cyan

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TempExe = "$env:TEMP\VisualCppRedist_AIO.exe"

try {
    $GithubApiUrl = "https://api.github.com/repos/abbodi1406/vcredist/releases/latest"
    $ReleaseInfo  = Invoke-RestMethod -Uri $GithubApiUrl -UseBasicParsing -ErrorAction Stop

    $DownloadUrl  = ($ReleaseInfo.assets | Where-Object { $_.name -like "*.exe" } | Select-Object -First 1).browser_download_url

    if (-not $DownloadUrl) {
        throw "Could not find .exe asset in latest GitHub release."
    }

    Write-Host "      -> Downloading from GitHub API..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempExe -UseBasicParsing -ErrorAction Stop

    Write-Host "      -> Executing silent installation (/y)..." -ForegroundColor Gray
    Start-Process -FilePath $TempExe -ArgumentList "/y" -Wait -NoNewWindow

    Remove-Item -Path $TempExe -Force -ErrorAction SilentlyContinue
    Write-Host "  [OK] VC++ Runtimes successfully installed from GitHub!" -ForegroundColor Green

} catch {
    Write-Host "  [!] Failed to fetch/install VC++ AIO online: $_" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 1. Microsoft Office 
# ------------------------------------------------------------------------------
$OfficeSetup = Join-Path $AppsDir "Office\setup.exe"
$OfficeConfig = Join-Path $AppsDir "Office\configuration.xml"

if ((Test-Path $OfficeSetup) -and (Test-Path $OfficeConfig)) {
    Write-Host "  [+] Installing Microsoft Office 2024 Full..." -ForegroundColor Gray
    Start-Process -FilePath $OfficeSetup -ArgumentList "/configure `"$OfficeConfig`"" -Wait -NoNewWindow
    Write-Host "  [OK] Office installed successfully!" -ForegroundColor Green
} else {
    Write-Host "  [-] Office setup files not found, skipping..." -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# 2. Adobe Acrobat Reader / DC (MSI 或 EXE 靜默)
# ------------------------------------------------------------------------------
# $AcrobatMsi = Join-Path $AppsDir "Acrobat\AcroRead.msi"
# $AcrobatExe = Join-Path $AppsDir "Acrobat\AcroRdrDC.exe"

# if (Test-Path $AcrobatMsi) {
#    Write-Host "  [+] Installing Adobe Acrobat (MSI)..." -ForegroundColor Gray
#    Start-Process msiexec.exe -ArgumentList "/i `"$AcrobatMsi`" /qn /norestart EULA_ACCEPT=YES" -Wait -NoNewWindow
#    Write-Host "  [OK] Adobe Acrobat installed successfully!" -ForegroundColor Green
#} elseif (Test-Path $AcrobatExe) {
#    Write-Host "  [+] Installing Adobe Acrobat (EXE)..." -ForegroundColor Gray
#    Start-Process -FilePath $AcrobatExe -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait -NoNewWindow
#    Write-Host "  [OK] Adobe Acrobat installed successfully!" -ForegroundColor Green
#} else {
#    Write-Host "  [-] Adobe Acrobat installer not found, skipping..." -ForegroundColor Yellow
#}

# ------------------------------------------------------------------------------
# 3. PotPlayer
# ------------------------------------------------------------------------------
Write-Host "  [+] Downloading & Installing Latest PotPlayer..." -ForegroundColor Gray
$PotPlayerUrl  = "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe"
$PotPlayerTemp = "$env:TEMP\PotPlayerSetup64.exe"

try {
    Invoke-WebRequest -Uri $PotPlayerUrl -OutFile $PotPlayerTemp -UseBasicParsing -ErrorAction Stop
    Start-Process -FilePath $PotPlayerTemp -ArgumentList "/S" -Wait -NoNewWindow
    Remove-Item -Path $PotPlayerTemp -Force -ErrorAction SilentlyContinue
    Write-Host "  [OK] Latest PotPlayer installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "  [!] Failed to download/install PotPlayer online: $_" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 4. K-Lite Codec Pack Mega
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
