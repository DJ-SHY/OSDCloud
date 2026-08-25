Write-Host "[OSDCloud] Downloading unattend.xml from GitHub..." -ForegroundColor Cyan

$UnattendUrl = "https://raw.githubusercontent.com/DJ-SHY/OSDCloud/main/Unattended.xml"
try {
    Invoke-WebRequest -Uri $UnattendUrl -OutFile "X:\unattend.xml" -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "[!] Failed to download unattend.xml: $_" -ForegroundColor Red
}


if (Test-Path "X:\unattend.xml") {
    $PantherPath = "C:\Windows\Panther"
    if (-not (Test-Path $PantherPath)) { 
        New-Item -Path $PantherPath -ItemType Directory -Force | Out-Null 
    }
    
    Copy-Item -Path "X:\unattend.xml" -Destination "$PantherPath\unattend.xml" -Force
    Write-Host "[OK] Successfully injected unattend.xml to $PantherPath" -ForegroundColor Green
}