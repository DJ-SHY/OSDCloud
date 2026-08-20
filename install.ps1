# ==============================================================================
# File: install.ps1 (With Custom System Tweaks & Selected Debloat)
# Path: C:\Windows\Setup\Scripts\install.ps1
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

Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Enabling .NET Framework 3.5" -PercentComplete $OverallPercent
Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Running DISM Online Enable-Feature..." -PercentComplete 10

Write-Host "[$CurrentStep/$TotalSteps] Installing .NET Framework 3.5..." -ForegroundColor Yellow
dism /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart | Out-Null

Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Completed .NET 3.5!" -PercentComplete 100
Write-Host " -> .NET Framework 3.5 installed successfully!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# STEP 2/3: Language Packs (zh-HK, zh-CN, ja-JP) & Set Default UI to en-US
# ------------------------------------------------------------------------------
$CurrentStep = 2
$Langs = @('zh-HK', 'zh-CN', 'ja-JP')
Write-Host "[$CurrentStep/$TotalSteps] Installing Language Packs ($($Langs.Count) total)..." -ForegroundColor Yellow

$LangIndex = 0
foreach ($Lang in $Langs) {
    $LangIndex++
    
    $SubPercent = [int](($LangIndex - 1) / $Langs.Count * 100)
    $OverallPercent = [int](33 + (($LangIndex - 1) / $Langs.Count * 30))

    Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Installing Languages ($LangIndex/$($Langs.Count))" -PercentComplete $OverallPercent
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: $Lang" -Status "Downloading and applying $Lang..." -PercentComplete $SubPercent

    Write-Host "  [+] [$LangIndex/$($Langs.Count)] Processing language pack: $Lang..." -ForegroundColor Gray
    Install-Language -Language $Lang -CopyToSettings
}

Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Locking Default UI Language to en-US" -PercentComplete 63
Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: Default Language" -Status "Locking system UI to en-US..." -PercentComplete 90

Write-Host "  [+] Finalizing default language configuration for en-US..." -ForegroundColor Gray
Install-Language -Language en-US -CopyToSettings
# Set-SystemUILanguage -Language en-US
# Set-WinUILanguageOverride -Language en-US

Write-Host " -> All language packs installed & Default UI locked to en-US!" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# STEP 3/3: Debloat Apps & Apply Custom System Tweaks
# ------------------------------------------------------------------------------
$CurrentStep = 3
Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Debloating & Applying System Tweaks" -PercentComplete 66
Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Removing Selected Provisioned Apps..." -PercentComplete 10

Write-Host "[$CurrentStep/$TotalSteps] Debloating Apps & Applying Selected System Tweaks..." -ForegroundColor Yellow

$BloatApps = @(
    "*MSTeams*", "*MicrosoftTeams*", "*MicrosoftOfficeHub*", "*OneDrive*",
    "*OutlookForWindows*", "*BingNews*", "*BingSearch*", "*BingWeather*",
    "*Clipchamp*", "*WindowsFeedbackHub*", "*GetHelp*", "*ZuneMusic*", "*ZuneVideo*"
)

foreach ($App in $BloatApps) {
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App -or $_.PackageName -like $App } | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
    }
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $App } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Out-Null
}
Write-Host " -> Selected Apps debloated successfully!" -ForegroundColor Green

# ==============================================================================
Write-Host "  [+] Completely removing OneDrive & preventing auto-reinstall..." -ForegroundColor Gray

$OneDriveSetup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
$OneDriveSetup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"

if (Test-Path $OneDriveSetup64) {
    Start-Process $OneDriveSetup64 -ArgumentList "/uninstall" -Wait -NoNewWindow
} elseif (Test-Path $OneDriveSetup32) {
    Start-Process $OneDriveSetup32 -ArgumentList "/uninstall" -Wait -NoNewWindow
}

Remove-Item -Path $OneDriveSetup32 -Force -ErrorAction SilentlyContinue
Remove-Item -Path $OneDriveSetup64 -Force -ErrorAction SilentlyContinue

$OneDrivePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
if (-not (Test-Path $OneDrivePolicy)) { New-Item -Path $OneDrivePolicy -Force | Out-Null }
Set-ItemProperty -Path $OneDrivePolicy -Name "DisableFileSyncNGSC" -Type DWord -Value 1 -Force

reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT" | Out-Null

Remove-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -ErrorAction SilentlyContinue

$OneDriveCLSID = "HKU:\DefaultUser\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
if (-not (Test-Path $OneDriveCLSID)) { New-Item -Path $OneDriveCLSID -Force | Out-Null }
Set-ItemProperty -Path $OneDriveCLSID -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 0 -Force

reg unload "HKU\DefaultUser" | Out-Null
# ==============================================================================

Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Applying System-wide (HKLM) Tweaks..." -PercentComplete 40

$Paths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI",
    "HKLM:\SOFTWARE\Policies\Microsoft\Edge",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors",
    "HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice"
)
foreach ($p in $Paths) { if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null } }

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type DWord -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "CopilotCDPPageContext" -Type DWord -Value 0 -Force

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Type DWord -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice" -Name "AllowFindMyDevice" -Type DWord -Value 0 -Force

Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Applying Default User Profile Registry Tweaks..." -PercentComplete 70
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT" | Out-Null

$UserPaths = @(
    "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
    "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search",
    "HKU:\DefaultUser\Software\Policies\Microsoft\Windows\Explorer",
    "HKU:\DefaultUser\Software\Policies\Microsoft\Windows\WindowsCopilot",
    "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
    "HKU:\DefaultUser\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32",
    "HKU:\DefaultUser\Control Panel\Accessibility\StickyKeys"
)
foreach ($up in $UserPaths) { if (-not (Test-Path $up)) { New-Item -Path $up -Force | Out-Null } }

# [Start Menu & Search]
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" -Name "DeviceHistoryEnabled" -Type DWord -Value 0 -Force

Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 2 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -Type DWord -Value 1 -Force

# [AI & Copilot (User Level)]
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force

Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 2 -Force

Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -Force

Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0 -Force
Set-ItemProperty -Path "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSpotlightOnDesktop" -Type DWord -Value 0 -Force

Set-ItemProperty -Path "HKU:\DefaultUser\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Type String -Value "" -Force

Set-ItemProperty -Path "HKU:\DefaultUser\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506" -Force

[GC]::Collect()
[GC]::WaitForPendingFinalizers()
reg unload "HKU\DefaultUser" | Out-Null

Write-Host " -> System & Default Profile tweaks applied successfully!" -ForegroundColor Green
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
