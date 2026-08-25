Write-Host "[OSDCloud] Fetching & Installing .NET 3.5 directly from Microsoft..." -ForegroundColor Yellow
try {
    Add-WindowsCapability -Online -Name "NetFX3~~~~" -ErrorAction Stop | Out-Null
    Write-Host " -> .NET 3.5 installed successfully from Microsoft!" -ForegroundColor Green
} catch {
    Write-Host " [!] Failed to install .NET 3.5: $_" -ForegroundColor Red
}