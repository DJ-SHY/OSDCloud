# ==============================================================================
# File: 08.InstallSoft.ps1
# Path: C:\Windows\Setup\Scripts\08.Installsoft.ps1
# ==============================================================================
Write-Host "[!] Installing Software Packages..." -ForegroundColor Yellow

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

$TempExe = "$env:TEMP\VisualCppRedist_AIO_x86_x64.exe"

try {
    $GithubApiUrl = "https://api.github.com/repos/abbodi1406/vcredist/releases/latest"
    $ReleaseInfo  = Invoke-RestMethod -Uri $GithubApiUrl -UseBasicParsing -ErrorAction Stop

    $DownloadUrl  = ($ReleaseInfo.assets | Where-Object { $_.name -like "*x86_x64*.exe" } | Select-Object -First 1).browser_download_url

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
$OfficeConfig = Join-Path $AppsDir "Office\configuration24.xml"

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

# ==========================================
# 5. Install .NET 8 Desktop Runtime (x64)
# ==========================================

Write-Host "[!] Installing .NET Desktop Runtime..." -ForegroundColor Cyan

$TempDir = "$env:TEMP\DotNet8"
if (-not (Test-Path $TempDir)) { 
    New-Item -Path $TempDir -ItemType Directory -Force | Out-Null 
}

# Replace with your self-hosted R2 URL or Microsoft direct link
$DotNet8Url = "https://chows.cloud/MSNET/windowsdesktopruntime8x64.exe"
$InstallerPath = Join-Path -Path $TempDir -ChildPath "dotnet8-desktop-runtime.exe"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
$ProgressPreference = 'SilentlyContinue'

$TempDir = "$env:TEMP\DotNetInstall"
if (-not (Test-Path $TempDir)) { New-Item -Path $TempDir -ItemType Directory -Force | Out-Null }

try {
    Write-Host "  [+] Downloading .NET 8 Desktop Runtime..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $DotNet8Url -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
    Write-Host "  [OK] Download completed successfully." -ForegroundColor Green
    
    Write-Host "  [+] Running silent installation..." -ForegroundColor Gray
    # Microsoft official silent flags: /install /quiet /norestart
    Start-Process -FilePath $InstallerPath -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow
    Write-Host "  [OK] .NET 8 Desktop Runtime installed successfully." -ForegroundColor Green
} catch {
    Write-Host "  [!] Failed to install .NET 8 Desktop Runtime: $_" -ForegroundColor Red
} finally {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

# ==========================================
# Install .NET 10 Desktop Runtime (x64)
# ==========================================

Write-Host "[!] Installing .NET 10 Desktop Runtime..." -ForegroundColor Cyan

$TempDir = "$env:TEMP\DotNet10"
if (-not (Test-Path $TempDir)) { 
    New-Item -Path $TempDir -ItemType Directory -Force | Out-Null 
}

# Replace with your self-hosted R2 URL or Microsoft direct link
$DotNet10Url = "https://chows.cloud/MSNET/windowsdesktopruntime10x64.exe"
$InstallerPath = Join-Path -Path $TempDir -ChildPath "dotnet10-desktop-runtime.exe"

try {
    Write-Host "  [+] Downloading .NET 10 Desktop Runtime..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $DotNet10Url -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
    Write-Host "  [OK] Download completed successfully." -ForegroundColor Green
    
    Write-Host "  [+] Running silent installation..." -ForegroundColor Gray
    # Microsoft official silent flags: /install /quiet /norestart
    Start-Process -FilePath $InstallerPath -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow
    Write-Host "  [OK] .NET 10 Desktop Runtime installed successfully." -ForegroundColor Green
} catch {
    Write-Host "  [!] Failed to install .NET 10 Desktop Runtime: $_" -ForegroundColor Red
} finally {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

# ==========================================
# Detect Dell Hardware & Install Dell Command | Update
# ==========================================

Write-Host "[!] Checking hardware manufacturer..." -ForegroundColor Cyan

$SystemInfo = Get-CimInstance -ClassName Win32_ComputerSystem
$Manufacturer = $SystemInfo.Manufacturer

if ($Manufacturer -match "Dell") {
    Write-Host "[OK] Dell hardware detected: $Manufacturer" -ForegroundColor Green
    Write-Host "[OSDCloud] Downloading Dell Command | Update Universal..." -ForegroundColor Cyan

    $TempDir = "$env:TEMP\DellDCU"
    if (-not (Test-Path $TempDir)) { 
        New-Item -Path $TempDir -ItemType Directory -Force | Out-Null 
    }

    # Dell Command | Update Universal Installer Official URL
    $DcuUrl = "https://chows.cloud/DellCommandUpdate.EXE"
    $InstallerPath = Join-Path -Path $TempDir -ChildPath "DCU_Setup.exe"

    try {
        Invoke-WebRequest -Uri $DcuUrl -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
        Write-Host "  [OK] Download completed successfully." -ForegroundColor Green
        
        Write-Host "[!] Installing Dell Command | Update silently..." -ForegroundColor Cyan
        # Silent install flag for Dell Update packages is /s
        Start-Process -FilePath $InstallerPath -ArgumentList "/s" -Wait -NoNewWindow
        Write-Host "  [OK] Dell Command | Update installation finished." -ForegroundColor Green
    } catch {
        Write-Host "  [!] Failed to download or install Dell Command | Update: $_" -ForegroundColor Red
    } finally {
        # Clean up temporary installer
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "[!] Non-Dell hardware detected ($Manufacturer). Skipping Dell Command | Update installation." -ForegroundColor Yellow
}
Write-Host " -> All software installation tasks completed!" -ForegroundColor Green
