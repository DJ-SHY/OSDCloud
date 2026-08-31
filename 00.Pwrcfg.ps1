# ==========================================
# Configure Power & Battery Settings (Universal for Desktop & Laptop)
# ==========================================

Write-Host "[!] Applying universal Power & Battery settings..." -ForegroundColor Cyan

# 1. Completely disable Hibernation globally (Deletes hiberfil.sys and frees disk space)
powercfg /hibernate off

# 2. Set Power Mode (Windows 11 Settings UI Overlay via Registry)
# Values: 0 = Recommended/Balanced, 1 = Better Performance, 2 = Best Performance
$PowerRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes"
if (Test-Path $PowerRegPath) {
    Set-ItemProperty -Path $PowerRegPath -Name "ActiveOverlayAcPowerMode" -Value 2 -Type DWord -ErrorAction SilentlyContinue # Plugged in -> Best Performance
    Set-ItemProperty -Path $PowerRegPath -Name "ActiveOverlayDcPowerMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue # On battery -> Balanced
}

# 3. Configure Plugged-in (AC) Timeouts (Screen = 5m, Sleep = Never)
powercfg /change monitor-timeout-ac 5
powercfg /change standby-timeout-ac 0

# 4. Commit and activate power scheme changes
powercfg /setactive SCHEME_CURRENT

Write-Host "[OK] Hibernation completely disabled." -ForegroundColor Green
Write-Host "[OK] Universal power settings successfully applied." -ForegroundColor Green
