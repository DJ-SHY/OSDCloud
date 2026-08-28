# ==========================================
# Configure Power & Battery Settings (Matching Screenshot)
# ==========================================

Write-Host "[!] Applying Power & Battery settings..." -ForegroundColor Cyan

# 1. Set Power Mode Overlays: Plugged in -> Best Performance (3), On battery -> Balanced (0)
$OverlayGUID = "5f3b5d2b-4d96-4222-b520-b04017d422d8"
powercfg /setacvalueindex SCHEME_CURRENT SUB_NONE $OverlayGUID 3
powercfg /setdcvalueindex SCHEME_CURRENT SUB_NONE $OverlayGUID 0
powercfg /setactive SCHEME_CURRENT

# 2. Set Plugged-in (AC) Timeouts
powercfg /change monitor-timeout-ac 5
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

Write-Host "[OK] Power mode set: AC=Best Performance, DC=Balanced." -ForegroundColor Green
Write-Host "[OK] Timeouts set: Screen=5m, Sleep=Never, Hibernate=Never." -ForegroundColor Green
