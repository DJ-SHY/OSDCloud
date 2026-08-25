Write-Host "[OSDCloud] Debloating Selected Provisioned Apps..." -ForegroundColor Yellow

$BloatApps = @(
    "*MSTeams*", "*MicrosoftTeams*", "*MicrosoftOfficeHub*", "*OneDrive*",
    "*OutlookForWindows*", "*BingNews*", "*BingSearch*", "*BingWeather*", "*WebExperience*",
    "*Clipchamp*", "*WindowsFeedbackHub*", "*GetHelp*", "*ZuneMusic*", "*ZuneVideo*"
)

foreach ($App in $BloatApps) {
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App -or $_.PackageName -like $App } | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
    }
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $App } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Out-Null
}
Write-Host " -> Selected Apps debloated successfully!" -ForegroundColor Green