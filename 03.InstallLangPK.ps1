# ==========================================
# Install Multi-Language Packages from R2
# Default UI: en-US | Non-Unicode (System Locale): zh-HK
# ==========================================

$R2BaseUrl = "https://chows.cloud/LP"

$TempDir = "$env:TEMP\R2LangPkg"
if (-not (Test-Path $TempDir)) { 
    New-Item -Path $TempDir -ItemType Directory -Force | Out-Null 
}

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

Write-Host "[!] Downloading Multi-Language Packages from Cloudflare R2..." -ForegroundColor Cyan

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

Write-Host "[!] Injecting Language Packages via DISM..." -ForegroundColor Cyan
$DownloadedFiles = Get-ChildItem -Path $TempDir | Where-Object { $_.Extension -in ".esd", ".cab" }

foreach ($Pkg in $DownloadedFiles) {
    try {
        Write-Host "  [+] Injecting $($Pkg.Name)..." -ForegroundColor Gray
        Add-WindowsPackage -Online -PackagePath $Pkg.FullName -NoRestart -ErrorAction Stop
        Write-Host "  [OK] Successfully injected $($Pkg.Name)" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Failed to inject $($Pkg.Name) : $_" -ForegroundColor Red
    }
}

Write-Host "[!] Configuring Locales (Default: en-US | Non-Unicode: zh-HK)..." -ForegroundColor Cyan

try {
    Set-Culture -CultureInfo en-US
    Set-WinSystemLocale -SystemLocale zh-HK
    Set-WinHomeLocation -GeoId 205
    Set-WinUILanguageOverride -Language en-US
）
    $UserLang = New-WinUserLanguageList -Language "en-US"
    $UserLang.Add("zh-HK")
    $UserLang.Add("zh-CN")
    $UserLang.Add("ja-JP")
    Set-WinUserLanguageList -LanguageList $UserLang -Force

    Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUserTemplate $true

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

    Write-Host "  [OK] Language settings successfully set (en-US UI / zh-HK Non-Unicode) & Applied to System!" -ForegroundColor Green
} catch {
    Write-Host "  [!] Failed to apply locale settings: $_" -ForegroundColor Red
} finally {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Temporary language files cleaned up." -ForegroundColor Green
}
