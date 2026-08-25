# ==============================================================================
# File: install.ps1 (Master Orchestrator)
# Path: C:\Windows\Setup\Scripts\install.ps1
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "*** System Initialization in Progress - Do Not Turn Off ***"
Clear-Host

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   Executing Post-Install Modular Setup Tasks            " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = "C:\Windows\Setup\Scripts"
$Modules = @(
    @{ Name = "02-InstallDotNet35.ps1"; Desc = "Installing .NET Framework 3.5" },
    @{ Name = "03-InstallLanguagePacks.ps1"; Desc = "Installing Language Packs" },
    @{ Name = "04-DebloatApps.ps1"; Desc = "Debloating Provisioned Apps" },
    @{ Name = "05-RemoveOneDrive.ps1"; Desc = "Removing OneDrive" },
    @{ Name = "06-ApplyRegistryTweaks.ps1"; Desc = "Applying Registry & System Tweaks" },
    @{ Name = "07-ApplyStartMenu.ps1"; Desc = "Applying Custom Start Menu" }
)

$TotalSteps = $Modules.Count
$CurrentStep = 0

foreach ($Module in $Modules) {
    $CurrentStep++
    $Percent = [int](($CurrentStep / $TotalSteps) * 100)
    $ScriptPath = Join-Path -Path $ScriptDir -ChildPath $Module.Name

    Write-Progress -Id 1 -Activity "Overall System Setup" -Status "[$CurrentStep/$TotalSteps] $($Module.Desc)" -PercentComplete $Percent
    
    if (Test-Path $ScriptPath) {
        Write-Host "[$CurrentStep/$TotalSteps] Running $($Module.Name)..." -ForegroundColor Yellow
        & $ScriptPath
    } else {
        Write-Host " [!] Module missing: $ScriptPath" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Progress -Id 1 -Activity "Overall System Setup" -Status "Complete!" -PercentComplete 100

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   All modular tasks completed. Rebooting in 5 seconds.  " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

Start-Sleep -Seconds 2
Write-Progress -Id 1 -Activity " " -Status " " -Completed

shutdown.exe /r /t 5 /c "Post-installation modular setup complete. Rebooting system..."

exit 0