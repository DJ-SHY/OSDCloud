# 設定視窗標題
$Host.UI.RawUI.WindowTitle = "*** 系統初始化設定中 - 請勿關閉電腦 ***"
Clear-Host

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   正在執行 SetupComplete 系統自動預裝程式" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- 步驟 1: 安裝 .NET Framework 3.5 ---
Write-Progress -Activity "Windows 系統初始化" -Status "步驟 1/3: 正在啟用 .NET Framework 3.5..." -PercentComplete 20
Write-Host "[1/3] 正在安裝 .NET Framework 3.5..." -ForegroundColor Yellow
dism /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart | Out-Null
Write-Host " -> .NET 3.5 安裝完成！" -ForegroundColor Green
Write-Host ""

# --- 步驟 2: 安裝多國語言包 ---
Write-Progress -Activity "Windows 系統初始化" -Status "步驟 2/3: 正在下載並安裝多國語言包 (需時較長)..." -PercentComplete 50
Write-Host "[2/3] 正在安裝多國語言包 (en-US, zh-TW, zh-CN, ja-JP)..." -ForegroundColor Yellow

$Langs = @('en-US', 'zh-TW', 'zh-CN', 'ja-JP')
$count = 0
foreach ($Lang in $Langs) {
    $count++
    $percent = [int](50 + ($count / $Langs.Count * 30))
    Write-Progress -Activity "Windows 系統初始化" -Status "步驟 2/3: 正在下載 $Lang ($count/$($Langs.Count))..." -PercentComplete $percent
    Write-Host "  [+] 正在處理語言包: $Lang ..." -ForegroundColor Gray
    Install-Language -Language $Lang -CopyToSettings
}
Write-Host " -> 所有語言包安裝完成！" -ForegroundColor Green
Write-Host ""

# --- 步驟 3: 安裝預裝軟件 ---
Write-Progress -Activity "Windows 系統初始化" -Status "步驟 3/3: 正在安裝 Google Chrome & 7-Zip..." -PercentComplete 85
Write-Host "[3/3] 正在安裝應用程式..." -ForegroundColor Yellow

Write-Host "  [+] 安裝 Google Chrome..." -ForegroundColor Gray
winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements | Out-Null

Write-Host "  [+] 安裝 7-Zip..." -ForegroundColor Gray
winget install --id 7zip.7zip -e --silent --accept-source-agreements --accept-package-agreements | Out-Null

Write-Host " -> 軟件安裝完成！" -ForegroundColor Green
Write-Host ""

# --- 完成 ---
Write-Progress -Activity "Windows 系統初始化" -Status "全部完成！準備進入 Windows..." -PercentComplete 100
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   所有初始化項目已成功完成，3 秒後自動進入系統" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Start-Sleep -Seconds 3