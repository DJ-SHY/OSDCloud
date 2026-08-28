# ==========================================
# Configure Power & Battery Settings (Universal for Desktop & Laptop)
# Includes disabling Hibernation completely
# ==========================================

Write-Host "[!] Applying universal Power & Battery settings..." -ForegroundColor Cyan

# 1. Completely disable Hibernation globally (Deletes hiberfil.sys and frees disk space)
powercfg /hibernate off

# 2. Set Power Mode Overlays: Plugged in -> Best Performance (3), On battery -> Balanced (0)
$OverlayGUID = "5f3b5d2b-4d96-4222-b520-b04017d422d8"
powercfg /setacvalueindex SCHEME_CURRENT SUB_NONE $OverlayGUID 3
powercfg /setdcvalueindex SCHEME_CURRENT SUB_NONE $OverlayGUID 0

# 3. Configure Plugged-in (AC) Timeouts (Screen = 5m, Sleep = Never)
powercfg /change monitor-timeout-ac 5
powercfg /change standby-timeout-ac 0

# 4. Commit and activate power scheme changes
powercfg /setactive SCHEME_CURRENT

Write-Host "[OK] Hibernation completely disabled." -ForegroundColor Green
Write-Host "[OK] Universal power settings successfully applied." -ForegroundColor Green
