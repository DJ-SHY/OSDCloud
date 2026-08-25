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

# ------------------------------------------------------------------------------
# 
# ------------------------------------------------------------------------------
Write-Host "[OSDCloud] Unlocking Online FOD & Microsoft Update Policy..." -ForegroundColor Cyan

$ServicingKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing"
if (-not (Test-Path $ServicingKey)) { New-Item -Path $ServicingKey -Force | Out-Null }
Set-ItemProperty -Path $ServicingKey -Name "LocalSourceConfigForFeatures" -Value 2 -Type DWord -Force
Set-ItemProperty -Path $ServicingKey -Name "RepairContentServerSource" -Value 2 -Type DWord -Force

$WuKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $WuKey)) { New-Item -Path $WuKey -Force | Out-Null }
Set-ItemProperty -Path $WuKey -Name "UseWUServer" -Value 0 -Type DWord -Force

Set-Service -Name "wuauserv" -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name "bits" -StartupType Automatic -ErrorAction SilentlyContinue
Restart-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Restart-Service -Name "bits" -Force -ErrorAction SilentlyContinue
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
$dismResult = $LASTEXITCODE

if ($dismResult -eq 0 -or $dismResult -eq 3010) {
    Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Completed .NET 3.5!" -PercentComplete 100
    Write-Host " -> .NET Framework 3.5 installed successfully!" -ForegroundColor Green
} else {
    Write-Host " [!] .NET Framework 3.5 installation failed with Exit Code: $dismResult" -ForegroundColor Red
}
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
    try {
        Install-Language -Language $Lang -CopyToSettings -ErrorAction Stop
    } catch {
        Write-Host "  [!] Failed to install $Lang : $_" -ForegroundColor Red
    }
}

Write-Progress -Id 1 -Activity "Overall Progress" -Status "Step $($CurrentStep)/$($TotalSteps): Locking Default UI Language to en-US" -PercentComplete 63
Write-Progress -Id 2 -ParentId 1 -Activity "Current Component: Default Language" -Status "Locking system UI to en-US..." -PercentComplete 90

Write-Host "  [+] Finalizing default language configuration for en-US..." -ForegroundColor Gray
try {
    Install-Language -Language en-US -CopyToSettings -ErrorAction SilentlyContinue
} catch {}

Write-Host " -> All language packs processed!" -ForegroundColor Green
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
    "*OutlookForWindows*", "*BingNews*", "*BingSearch*", "*BingWeather*", "*WebExperience*",
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
# OneDrive Completely Removal
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

# ==============================================================================
# Registry Tweaks & Default Hive Processing
# ==============================================================================
Write-Progress -Id 2 -ParentId 1 -Activity "Component Progress" -Status "Applying System-wide (HKLM & Default Hive) Tweaks..." -PercentComplete 40


reg.exe unload "HKU\Default" 2>$null | Out-Null


reg.exe load "HKU\Default" "C:\Users\Default\NTUSER.DAT" | Out-Null


Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "AllowRecallEnablement" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "TurnOffSavingSnapshots" /t REG_DWORD /d 1 /f | Out-Null

Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\WSAIFabricSvc" /v "Start" /t REG_DWORD /d 3 /f | Out-Null


Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "NewTabPageContentEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "NewTabPageHideDefaultTopSites" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "EdgeShoppingAssistantEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "TabServicesEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "AlternateErrorPagesEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "UserFeedbackAllowed" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "ShowRecommendationsEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "WalletDonationEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "DefaultBrowserSettingEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "DefaultBrowserSettingsCampaignEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SpotlightExperiencesAndRecommendationsEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "ShowAcrobatSubscriptionButton" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "CopilotCDPPageContext" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "CopilotPageContext" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "EdgeEntraCopilotPageContext" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "EdgeHistoryAISearchEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "ComposeInlineEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "GenAILocalFoundationalModelSettings" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "NewTabPageBingChatEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "PersonalizationReportingEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d 0 /f | Out-Null

# App Policies
Reg.exe add "HKLM\SOFTWARE\Policies\WindowsNotepad" /v "DisableAIFeatures" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" /v "DisableCocreator" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" /v "DisableGenerativeFill" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" /v "DisableImageCreator" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" /v "DisableGenerativeErase" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" /v "DisableRemoveBackground" /t REG_DWORD /d 1 /f | Out-Null

# System & Privacy Policies
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableConsumerAccountStateContent" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v "AllowFindMyDevice" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableFirstLogonAnimation" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "EnableFirstLogonAnimation" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d 1 /f | Out-Null

# Default User (HKU\default) Registry Tweaks
Reg.exe add "HKU\default\Software\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012078010000000" /f | Out-Null
Reg.exe add "HKU\default\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "DisableAnimations" /t REG_SZ /d "reg add \"HKCU\Control Panel\Desktop\" /v UserPreferencesMask /t REG_BINARY /d 9012078010000000 /f" /f | Out-Null
Reg.exe add "HKU\default\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableSpotlightCollectionOnDesktop" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsDynamicSearchBoxEnabled" /t REG_DWORD /d 0 /f | Out-Null


Reg.exe add "HKU\default\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f | Out-Null

Reg.exe add "HKU\default\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications" /v "EnableAccountNotifications" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" /v "Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Mobility" /v "OptedIn" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_AccountNotifications" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackupReminder" /v "Enabled" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKU\default\Software\Microsoft\Windows\CurrentVersion\Start" /v "AllAppsViewMode" /t REG_DWORD /d 2 /f | Out-Null

[GC]::Collect()
[GC]::WaitForPendingFinalizers()
Start-Sleep -Seconds 1
reg.exe unload "HKU\Default" | Out-Null

Write-Host " -> System & Default Profile tweaks applied successfully!" -ForegroundColor Green
Write-Host ""

# ==============================================================================
# Default User Start Menu (start2.bin)
# ==============================================================================
Write-Host "  [+] Applying Custom Start Menu Layout (start2.bin) to Default Profile..." -ForegroundColor Gray

$DefaultStartBinDir = "C:\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

if (-not (Test-Path $DefaultStartBinDir)) {
    New-Item -Path $DefaultStartBinDir -ItemType Directory -Force | Out-Null
}

$SourceStartBin = "C:\Windows\Setup\Scripts\start2.bin"

try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DJ-SHY/OSDCloud/main/start2.bin" -OutFile $SourceStartBin -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "  [!] Failed to download start2.bin: $_" -ForegroundColor Red
}

if (Test-Path $SourceStartBin) {
    Copy-Item -Path $SourceStartBin -Destination "$DefaultStartBinDir\start2.bin" -Force
    Write-Host " -> start2.bin applied successfully to Default Profile!" -ForegroundColor Green
} else {
    Write-Host " -> Warning: $SourceStartBin not found, skipping..." -ForegroundColor Red
}

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
