[CmdletBinding()]
param(
    [Parameter()]
    [ArgumentCompleter(
        {
            param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            $buildTasks = (Invoke-Build ?).Name

            if ($WordToComplete) {
                $buildTasks.Where{ $_ -match "^$WordToComplete" }
            }
            else {
                $buildTasks
            }
        }
    )]
    [string]
    $Task = '.'
)

if (-not (Get-PackageProvider NuGet -ErrorAction Ignore)) {
    Write-Host "Installing NuGet package provider"
    Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -ForceBootstrap -Force
}

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if (-not (Get-Module -ListAvailable InvokeBuild)) {
    Write-Host "Getting InvokeBuild module"
    Install-Module InvokeBuild -Scope CurrentUser
}

Import-Module InvokeBuild

Invoke-Build $Task
