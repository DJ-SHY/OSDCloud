# ==============================================================================
# File: install.ps1 (With Dual Progress Bars: Overall + Component Level)
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "*** System Initialization in Progress - Do Not Turn Off ***"
Clear-Host

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   Executing SetupComplete Post-Install Tasks            " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

$TotalSteps = 3

# ------------------------------------------------------------------------------
# STEP 1/3: .NET Framework 3.5
# ------------------------------------------------------------------------------
$CurrentStep = 1
$OverallPercent = [int](($CurrentStep - 1) / $TotalSteps * 100)

Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $CurrentStep/$TotalSteps: Enabling .NET Framework 3.5" -PercentComplete $OverallPercent
Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Running DISM Online Enable-Feature..." -PercentComplete 10

Write-Host "[$CurrentStep/$TotalSteps] Installing .NET Framework 3.5..." -ForegroundColor Yellow
dism /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart | Out-Null

Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Completed .NET 3.5!" -PercentComplete 100
Write-Host " -> .NET Framework 3.5 installed successfully!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# STEP 2/3: Language Packs
# ------------------------------------------------------------------------------
$CurrentStep = 2
$Langs = @('zh-TW', 'zh-CN', 'ja-JP')
Write-Host "[$CurrentStep/$TotalSteps] Installing Language Packs ($($Langs.Count) total)..." -ForegroundColor Yellow

$LangIndex = 0
foreach ($Lang in $Langs) {
    $LangIndex++
    
    $SubPercent = [int](($LangIndex - 1) / $Langs.Count * 100)
   
    $OverallPercent = [int](33 + (($LangIndex - 1) / $Langs.Count * 33))

    Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $CurrentStep/$TotalSteps: Installing Languages ($LangIndex/$($Langs.Count))" -PercentComplete $OverallPercent
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: $Lang" -Status "Downloading and applying $Lang..." -PercentComplete $SubPercent

    Write-Host "  [+] [$LangIndex/$($Langs.Count)] Processing language pack: $Lang..." -ForegroundColor Gray
    Install-Language -Language $Lang -CopyToSettings

    $SubPercentCompleted = [int]($LangIndex / $Langs.Count * 100)
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: $Lang" -Status "Completed $Lang!" -PercentComplete $SubPercentCompleted
}

Write-Host " -> All language packs installed successfully!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# STEP 3/3: Applications (Winget)
# ------------------------------------------------------------------------------
$CurrentStep = 3
$Apps = @(
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "7-Zip";         Id = "7zip.7zip" }
)

Write-Host "[$CurrentStep/$TotalSteps] Installing Applications ($($Apps.Count) total)..." -ForegroundColor Yellow

$AppIndex = 0
foreach ($App in $Apps) {
    $AppIndex++
    
  
    $SubPercent = [int](($AppIndex - 1) / $Apps.Count * 100)
 
    $OverallPercent = [int](66 + (($AppIndex - 1) / $Apps.Count * 33))

    Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $CurrentStep/$TotalSteps: Installing Apps ($AppIndex/$($Apps.Count))" -PercentComplete $OverallPercent
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: $($App.Name)" -Status "Installing $($App.Name)..." -PercentComplete $SubPercent

    Write-Host "  [+] [$AppIndex/$($Apps.Count)] Installing $($App.Name)..." -ForegroundColor Gray
    winget install --id $App.Id -e --silent --accept-source-agreements --accept-package-agreements | Out-Null

    $SubPercentCompleted = [int]($AppIndex / $Apps.Count * 100)
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: $($App.Name)" -Status "Completed $($App.Name)!" -PercentComplete $SubPercentCompleted
}

Write-Host " -> All applications installed successfully!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# COMPLETE
# ------------------------------------------------------------------------------
Write-Progress -Id 1 -Activity "Overall Progress" -Status "Complete!" -PercentComplete 100
Write-Progress -Id 2 -ParentId 1 -Activity "Current Component" -Status "All Tasks Completed!" -PercentComplete 100

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   All tasks completed successfully. Entering OS...      " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

Start-Sleep -Seconds 2
Write-Progress -Id 2 -Activity " " -Status " " -Completed
Write-Progress -Id 1 -Activity " " -Status " " -Completed
Start-Sleep -Seconds 1
