Write-Host "[OSDCloud] Applying Custom Start Menu Layout (start2.bin)..." -ForegroundColor Gray

$DefaultStartBinDir = "C:\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
if (-not (Test-Path $DefaultStartBinDir)) {
    New-Item -Path $DefaultStartBinDir -ItemType Directory -Force | Out-Null
}

$SourceStartBin = "C:\Windows\Setup\Scripts\start2.bin"

try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DJ-SHY/OSDCloud/main/start2.bin" -OutFile $SourceStartBin -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "  [!] Failed to download start2.bin: $_" -ForegroundColor Red
}

if (Test-Path $SourceStartBin) {
    Copy-Item -Path $SourceStartBin -Destination "$DefaultStartBinDir\start2.bin" -Force
    Write-Host " -> start2.bin applied successfully to Default Profile!" -ForegroundColor Green
} else {
    Write-Host " -> Warning: $SourceStartBin not found, skipping..." -ForegroundColor Red
}
