Write-Host "[!] Completely removing OneDrive..." -ForegroundColor Gray

$OneDriveSetup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
$OneDriveSetup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"

if (Test-Path $OneDriveSetup64) {
    Start-Process $OneDriveSetup64 -ArgumentList "/uninstall" -Wait -NoNewWindow
} elseif (Test-Path $OneDriveSetup32) {
    Start-Process $OneDriveSetup32 -ArgumentList "/uninstall" -Wait -NoNewWindow
}

Remove-Item -Path $OneDriveSetup32 -Force -ErrorAction SilentlyContinue
Remove-Item -Path $OneDriveSetup64 -Force -ErrorAction SilentlyContinue
Write-Host " -> OneDrive removed successfully!" -ForegroundColor Green
