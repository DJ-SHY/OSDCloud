# ==============================================================================
# File: install.ps1 (With Auto-Exit & Auto-Restart)
# Path: C:\Windows\Setup\Scripts\install.ps1
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "*** System Initialization in Progress - Do Not Turn Off ***"
Clear-Host

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   Executing SetupComplete Post-Install Tasks            " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

$TotalSteps = 2

# ------------------------------------------------------------------------------
# STEP 1/2: .NET Framework 3.5
# ------------------------------------------------------------------------------
$CurrentStep = 1
$OverallPercent = [int](($CurrentStep - 1) / $TotalSteps * 100)

Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Enabling .NET Framework 3.5" -PercentComplete $OverallPercent
Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Running DISM Online Enable-Feature..." -PercentComplete 10

Write-Host "[$CurrentStep/$TotalSteps] Installing .NET Framework 3.5..." -ForegroundColor Yellow
dism /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart | Out-Null

Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Completed .NET 3.5!" -PercentComplete 100
Write-Host " -> .NET Framework 3.5 installed successfully!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# STEP 2/2: Additional Language Packs & Lock Default UI to en-US
# ------------------------------------------------------------------------------
$CurrentStep = 2
$Langs = @('zh-TW', 'zh-CN', 'ja-JP')
Write-Host "[$CurrentStep/$TotalSteps] Installing Language Packs ($($Langs.Count) total) & Setting Default UI..." -ForegroundColor Yellow

$LangIndex = 0
foreach ($Lang in $Langs) {
    $LangIndex++
    
    $SubPercent = [int](($LangIndex - 1) / $Langs.Count * 100)
    $OverallPercent = [int](50 + (($LangIndex - 1) / $Langs.Count * 40))

    Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Installing Languages ($LangIndex/$($Langs.Count))" -PercentComplete $OverallPercent
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: $Lang" -Status "Downloading and applying $Lang..." -PercentComplete $SubPercent

    Write-Host "  [+] [$LangIndex/$($Langs.Count)] Processing language pack: $Lang..." -ForegroundColor Gray
    Install-Language -Language $Lang
}

Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Setting Default UI Language to en-US" -PercentComplete 95
Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: Default Language" -Status "Setting system UI to en-US..." -PercentComplete 90

Write-Host "  [+] Applying CopyToSettings for en-US..." -ForegroundColor Gray
Install-Language -Language en-US -CopyToSettings
Set-SystemUILanguage -Language en-US
Set-WinUILanguageOverride -Language en-US

Write-Host " -> All language packs installed & Default UI locked to en-US successfully!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# COMPLETE & AUTO REBOOT
# ------------------------------------------------------------------------------
Write-Progress -Id 1 -Activity "Overall Progress" -Status "Complete!" -PercentComplete 100
Write-Progress -Id 2 -ParentId 1 -Activity "Current Component" -Status "All Tasks Completed!" -PercentComplete 100

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   All tasks completed. System will reboot in 5 seconds. " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

Start-Sleep -Seconds 2
Write-Progress -Id 2 -Activity " " -Status " " -Completed
Write-Progress -Id 1 -Activity " " -Status " " -Completed

shutdown.exe /r /t 5 /c "Post-installation setup complete. Rebooting system..."

exit 0
