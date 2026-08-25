Write-Host "[OSDCloud] Unlocking Windows Update & Installing .NET 3.5..." -ForegroundColor Cyan

# $ServicingKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing"
# if (-not (Test-Path $ServicingKey)) { New-Item -Path $ServicingKey -Force | Out-Null }
# Set-ItemProperty -Path $ServicingKey -Name "LocalSourceConfigForFeatures" -Value 2 -Type DWord -Force

# $WuKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
# if (-not (Test-Path $WuKey)) { New-Item -Path $WuKey -Force | Out-Null }
# Set-ItemProperty -Path $WuKey -Name "UseWUServer" -Value 0 -Type DWord -Force

# Set-Service -Name "wuauserv" -StartupType Automatic -ErrorAction SilentlyContinue
# Restart-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue

try {
    Add-WindowsCapability -Online -Name "NetFX3~~~~" -ErrorAction Stop | Out-Null
    Write-Host " -> .NET 3.5 installed successfully from Microsoft!" -ForegroundColor Green
} catch {
    Write-Host " [!] Failed to install .NET 3.5: $_" -ForegroundColor Red
}
