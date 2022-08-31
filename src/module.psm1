if (-not $IsMacOS -and -not $IsLinux) {
    if (-not (Test-Path $env:ChocolateyInstall\license\chocolatey.license.xml)) {
        throw "A licensed version of Chocolatey For Business is required to import and use this module"
    }
}
