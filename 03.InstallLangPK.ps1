# ==========================================
# Install Multi-Language Packages from R2 (Optimized)
# Default UI: en-US | Non-Unicode (System Locale): zh-HK
# ==========================================

# 1. Unlock CPU throttle during OSD setup
powercfg /s 8c5e7cd5-58d3-4f37-926b-71556e201656 2>$null
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null
powercfg /setactive SCHEME_CURRENT 2>$null

$R2BaseUrl = "https://chows.cloud/LP"
$TempDir   = "$env:TEMP\R2LangPkg"

if (-not (Test-Path $TempDir)) { 
    New-Item -Path $TempDir -ItemType Directory -Force | Out-Null 
}

# 2. R2 Package Manifest
$PackageFiles = @(
    # Main Language Packs (.esd)
    "Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-TW.esd",
    "Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd",
    "Microsoft-Windows-Client-LanguagePack-Package-amd64-ja-JP.esd",
    
    # Basic Features (.cab)
    "Microsoft-Windows-LanguageFeatures-Basic-zh-tw-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-Basic-zh-cn-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-Basic-ja-jp-Package-amd64.cab",
    
    # Handwriting (.cab)
    "Microsoft-Windows-LanguageFeatures-Handwriting-zh-tw-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-Handwriting-zh-cn-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-Handwriting-ja-jp-Package-amd64.cab",
    
    # OCR (.cab)
    "Microsoft-Windows-LanguageFeatures-OCR-zh-tw-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-OCR-zh-cn-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-OCR-ja-jp-Package-amd64.cab",
    
    # Speech (.cab)
    "Microsoft-Windows-LanguageFeatures-Speech-zh-hk-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-Speech-zh-tw-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-Speech-zh-cn-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-Speech-ja-jp-Package-amd64.cab",
    
    # TextToSpeech (.cab)
    "Microsoft-Windows-LanguageFeatures-TextToSpeech-zh-hk-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-TextToSpeech-zh-tw-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-TextToSpeech-zh-cn-Package-amd64.cab",
    "Microsoft-Windows-LanguageFeatures-TextToSpeech-ja-jp-Package-amd64.cab"
)

# 3. Download Packages
Write-Host "[!] Downloading Multi-Language Packages..." -ForegroundColor Cyan

foreach ($File in $PackageFiles) {
    $FileUrl = "$R2BaseUrl/$File"
    $Destination = Join-Path -Path $TempDir -ChildPath $File
    
    try {
        Write-Host "  [+] Downloading $File..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $FileUrl -OutFile $Destination -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "  [!] Download failed for $File : $_" -ForegroundColor Yellow
    }
}

# 4. Batch DISM Servicing Injection (Single Pass for Performance)
Write-Host "[!] Injecting Language Packages via DISM (Batch Mode)..." -ForegroundColor Cyan
$DownloadedFiles = (Get-ChildItem -Path $TempDir | Where-Object { $_.Extension -in ".esd", ".cab" }).FullName

if ($DownloadedFiles.Count -gt 0) {
    try {
        Add-WindowsPackage -Online -PackagePath $DownloadedFiles -NoRestart -ErrorAction Stop
        Write-Host "  [OK] Batch DISM injection completed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Batch injection failed, falling back to dism.exe: $_" -ForegroundColor Yellow
        dism.exe /Online /Add-Package /PackagePath:"$TempDir" /NoRestart
    }
}

# 5. System Locales & Default User NTUSER.DAT Fix
Write-Host "[!] Configuring System Locales & User Profile Templates..." -ForegroundColor Cyan

try {
    # OS Level Settings
    Set-Culture -CultureInfo en-US
    Set-WinSystemLocale -SystemLocale zh-HK
    Set-WinHomeLocation -GeoId 205
    Set-WinUILanguageOverride -Language en-US

    # SYSTEM Account Language List
    $UserLang = New-WinUserLanguageList -Language "en-US"
    $UserLang.Add("zh-HK")
    $UserLang.Add("zh-CN")
    $UserLang.Add("ja-JP")
    Set-WinUserLanguageList -LanguageList $UserLang -Force

    # Modify Default User Template (NTUSER.DAT)
    reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT" | Out-Null

    $LangPath = "HKU:\DefaultUser\Control Panel\International\User Profile"
    if (-not (Test-Path $LangPath)) { New-Item -Path $LangPath -Force | Out-Null }
    Set-ItemProperty -Path $LangPath -Name "Languages" -Value @("en-US", "zh-HK", "zh-CN", "ja-JP") -Type MultiString -Force

    $PreloadPath = "HKU:\DefaultUser\Keyboard Layout\Preload"
    if (-not (Test-Path $PreloadPath)) { New-Item -Path $PreloadPath -Force | Out-Null }
    Set-ItemProperty -Path $PreloadPath -Name "1" -Value "00000409" -Type String -Force
    Set-ItemProperty -Path $PreloadPath -Name "2" -Value "00000c04" -Type String -Force

    # RunOnce initialization for first login user context
    $RunOncePath = "HKU:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    if (-not (Test-Path $RunOncePath)) { New-Item -Path $RunOncePath -Force | Out-Null }
    $InitCmd = 'powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$L=New-WinUserLanguageList -Language en-US; $L.Add(''zh-HK''); $L.Add(''zh-CN''); $L.Add(''ja-JP''); Set-WinUserLanguageList -LanguageList $L -Force"'
    Set-ItemProperty -Path $RunOncePath -Name "InitLanguageList" -Value $InitCmd -Type String -Force

    [gc]::Collect()
    reg unload "HKU\DefaultUser" | Out-Null

    # Apply via XML for System / Welcome Screen
    $XmlPath = "$TempDir\intl_config.xml"
    $XmlContent = @"
<gs:GlobalizationServices xmlns:gs="urn:longhornGlobalizationUnattend">
    <gs:UserList>
        <gs:User SystemLocale="zh-HK" UserLocale="en-US" MachineLanguage="en-US" GeoID="205">
            <gs:InputPreferences>
                <gs:InputPreference ID="0409:00000409"/>
                <gs:InputPreference ID="0c04:00000c04"/>
                <gs:InputPreference ID="0804:00000804"/>
                <gs:InputPreference ID="0411:00000411"/>
            </gs:InputPreferences>
        </gs:User>
    </gs:UserList>
    <gs:SystemLocale Name="zh-HK"/>
    <gs:WelcomeScreen CopyTo="user, system"/>
</gs:GlobalizationServices>
"@
    Set-Content -Path $XmlPath -Value $XmlContent -Encoding UTF8
    Start-Process -FilePath "control.exe" -ArgumentList "intl.cpl,, /f:`"$XmlPath`"" -Wait -NoNewWindow

    Write-Host "  [OK] Language settings successfully applied!" -ForegroundColor Green
} catch {
    Write-Host "  [!] Failed to apply locale settings: $_" -ForegroundColor Red
} finally {
    # Clean up
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Temporary language files cleaned up." -ForegroundColor Green
}
