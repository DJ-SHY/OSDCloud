Write-Host "[OSDCloud] Fetching & Installing Language Packs directly from Microsoft..." -ForegroundColor Yellow
$Langs = @('zh-HK', 'zh-CN', 'ja-JP')

foreach ($Lang in $Langs) {
    Write-Host "  [+] Processing language pack: $Lang..." -ForegroundColor Gray
    try {
        Install-Language -Language $Lang -CopyToSettings -ErrorAction Stop
        Write-Host "  [OK] Successfully installed $Lang!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Failed to install $Lang: $_" -ForegroundColor Red
    }
}

Write-Host "  [+] Setting Default UI Language to en-US..." -ForegroundColor Gray
Install-Language -Language en-US -CopyToSettings -ErrorAction SilentlyContinue