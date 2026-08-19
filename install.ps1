# ==============================================================================
# File: install.ps1
# Path: C:\Windows\Setup\Scripts\install.ps1
# Description: Post-OSD setup script triggered by SetupComplete.cmd
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "*** System Initialization in Progress - Do Not Turn Off Computer ***"
Clear-Host

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   Executing SetupComplete Post-Install Tasks   " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Enable .NET Framework 3.5 ---
Write-Progress -Activity "Windows System Initialization" -Status "Step 1/3: Enabling .NET Framework 3.5..." -PercentComplete 20
Write-Host "[1/3] Installing .NET Framework 3.5..." -ForegroundColor Yellow
dism /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart | Out-Null
Write-Host " -> .NET Framework 3.5 installation completed!" -ForegroundColor Green
Write-Host ""

# --- Step 2: Install Language Packs ---
Write-Progress -Activity "Windows System Initialization" -Status "Step 2/3: Downloading and installing language packs (may take a while)..." -PercentComplete 50
Write-Host "[2/3] Installing language packs (en-US, zh-TW, zh-CN, ja-JP)..." -ForegroundColor Yellow

$Langs = @('en-US', 'zh-TW', 'zh-CN', 'ja-JP')
$count = 0
foreach ($Lang in $Langs) {
    $count++
    $percent = [int](50 + ($count / $Langs.Count * 30))
    Write-Progress -Activity "Windows System Initialization" -Status "Step 2/3: Downloading $Lang ($count/$($Langs.Count))..." -PercentComplete $percent
    Write-Host "  [+] Processing language pack: $Lang ..." -ForegroundColor Gray
    Install-Language -Language $Lang -CopyToSettings
}
Write-Host " -> All language packs installed successfully!" -ForegroundColor Green
Write-Host ""

# --- Step 3: Install Applications ---
Write-Progress -Activity "Windows System Initialization" -Status "Step 3/3: Installing Google Chrome & 7-Zip..." -PercentComplete 85
Write-Host "[3/3] Installing applications..." -ForegroundColor Yellow

Write-Host "  [+] Installing Google Chrome..." -ForegroundColor Gray
winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements | Out-Null

Write-Host "  [+] Installing 7-Zip..." -ForegroundColor Gray
winget install --id 7zip.7zip -e --silent --accept-source-agreements --accept-package-agreements | Out-Null

Write-Host " -> Application installation completed!" -ForegroundColor Green
Write-Host ""

# --- Complete ---
Write-Progress -Activity "Windows System Initialization" -Status "Complete! Preparing to launch Windows..." -PercentComplete 100
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   All tasks completed successfully. Entering OS in 3 seconds...   " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Start-Sleep -Seconds 3
