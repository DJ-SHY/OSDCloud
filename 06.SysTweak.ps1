Write-Host "[!] Applying System-wide (HKLM & Default Hive) Tweaks..." -ForegroundColor Yellow

reg.exe unload "HKU\Default" 2>$null | Out-Null
reg.exe load "HKU\Default" "C:\Users\Default\NTUSER.DAT" | Out-Null

# HKLM Policies
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "AllowRecallEnablement" /t REG_DWORD /d 0 /f | Out-Null
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "TurnOffSavingSnapshots" /t REG_DWORD /d 1 /f | Out-Null
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\WSAIFabricSvc" /v "Start" /t REG_DWORD /d 3 /f | Out-Null

# Edge Policies
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

# Default User Registry Tweaks
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

Write-Host " -> Registry tweaks applied successfully!" -ForegroundColor Green
