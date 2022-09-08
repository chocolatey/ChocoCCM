[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $OutputDirectory = "$PSScriptRoot/Output",

    [Parameter()]
    [string]
    $TimeStampServer = $(
        if ($env:CERT_TIMESTAMP_URL) {
            $env:CERT_TIMESTAMP_URL
        }
        else {
            'http://timestamp.digicert.com'
        }
    ),

    [string]
    $CertificatePath = $env:CHOCOLATEY_OFFICIAL_CERT,

    [string]
    $CertificatePassword = $env:CHOCOLATEY_OFFICIAL_CERT_PASSWORD,

    [Parameter()]
    [string]
    $CertificateAlgorithm = $(
        if ($env:CERT_ALGORITHM) {
            $env:CERT_ALGORITHM
        }
        else {
            'Sha256'
        }
    ),

    [string]
    $CertificateSubjectName = "Chocolatey Software, Inc.",

    [Parameter()]
    [string]
    $NugetApiKey = $env:POWERSHELLPUSH_API_KEY,

    [Parameter()]
    [string]
    $PublishUrl = $env:POWERSHELLPUSH_SOURCE
)

$ErrorActionPreference = 'Stop'

$script:SourceFolder = "$PSScriptRoot/src"
$script:ReleaseBuild = -not [string]::IsNullOrEmpty((git tag --points-at HEAD 2> $null) -replace '^v')
$script:BuildVersion = $null
$script:IsPrerelease = $false


# Fix for Register-PSRepository not working with https from StackOverflow:
# https://stackoverflow.com/questions/35296482/invalid-web-uri-error-on-register-psrepository/35296483#35296483
function Register-PSRepositoryFix {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [Uri]
        $SourceLocation,

        [ValidateSet('Trusted', 'Untrusted')]
        $InstallationPolicy = 'Trusted'
    )

    $ErrorActionPreference = 'Stop'

    try {
        Write-Verbose 'Trying to register via ​Register-PSRepository'
        Register-PSRepository -Name $Name -SourceLocation $SourceLocation -InstallationPolicy $InstallationPolicy -ErrorAction Stop
        Write-Verbose 'Registered via Register-PSRepository'
    }
    catch {
        Write-Verbose 'Register-PSRepository failed, registering via workaround'

        # Adding PSRepository directly to file
        Register-PSRepository -Name $Name -SourceLocation $env:TEMP -InstallationPolicy $InstallationPolicy -ErrorAction Stop
        $PSRepositoriesXmlPath = "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\PowerShellGet\PSRepositories.xml"
        $repos = Import-Clixml -Path $PSRepositoriesXmlPath
        $repos[$Name].SourceLocation = $SourceLocation.AbsoluteUri
        $repos[$Name].PublishLocation = [uri]::new($SourceLocation, 'package').AbsoluteUri
        $repos[$Name].ScriptSourceLocation = ''
        $repos[$Name].ScriptPublishLocation = ''
        $repos | Export-Clixml -Path $PSRepositoriesXmlPath

        # Reloading PSRepository list
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Write-Verbose 'Registered via workaround'
    }
}

# Synopsis: ensure GitVersion is installed
task InstallGitVersion {
    if (-not (Get-Command gitversion -ErrorAction Ignore)) {
        Write-Host "Installing Gitversion"
        choco install gitversion.portable -y --no-progress
    }
}

# Synopsis: ensure PowerShellGet has the NuGet provider installed
task BootstrapPSGet {
    if (-not (Get-PackageProvider NuGet -ErrorAction Ignore)) {
        Write-Host "Installing NuGet package provider"
        Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -ForceBootstrap -Force
    }

    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    if (-not (Get-InstalledModule PowerShellGet -MinimumVersion 2.0 -MaximumVersion 2.99 -ErrorAction Ignore)) {
        Install-Module PowerShellGet -MaximumVersion 2.99 -Force
        Remove-Module PowerShellGet -Force
        Import-Module PowerShellGet -MinimumVersion 2.0 -Force
    }
}

# Synopsis: ensure Pester is installed
task InstallPester BootstrapPSGet, {
    if (-not (Get-InstalledModule Pester -MaximumVersion 4.99 -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Pester"
        Install-Module Pester -MaximumVersion 4.99 -SkipPublisherCheck -Force -Scope CurrentUser -ErrorAction Stop -Verbose:$false
    }
}

# Synopsis: ensure PSScriptAnalyzer is installed
task InstallScriptAnalyzer BootstrapPSGet, {
    if (-not (Get-InstalledModule PSScriptAnalyzer -MinimumVersion 1.20 -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PSSA"
        Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -MinimumVersion 1.20 -ErrorAction Stop -Verbose:$false
    }
}

# Synopsis: cleanup build artifacts
task Clean {
    Write-Host "Removing any prior existing files from ./Output"
    remove $OutputDirectory
    $null = New-Item -Path $OutputDirectory -ItemType Directory
}

# Synopsis: run PSScriptAnalyzer on project files
task ScriptAnalyzer InstallScriptAnalyzer, {
    Write-Host "Checking project files with PSScriptAnalyzer"
    $results = Invoke-ScriptAnalyzer -Path $script:SourceFolder -Recurse -Settings "$PSScriptRoot/PSScriptAnalyzerSettings.psd1"
    if ($results) {
        Write-Host "PSSA rule violations found:" -ForegroundColor Red
        $results | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Red
        throw "PSSA rule violations detected, see above errors for more information"
    }
}

# Synopsis: build the project
task Build Clean, InstallGitVersion, ScriptAnalyzer, {
    $null = New-Item "$OutputDirectory/ChocoCCM" -ItemType Directory

    $manifest = Copy-Item "$script:SourceFolder/ChocoCCM.psd1" -Destination "$OutputDirectory/ChocoCCM" -PassThru

    $moduleScripts = @(
        Get-Item "$script:SourceFolder/module.psm1"
        Get-Item "$script:SourceFolder/Private/*.ps1"
        Get-Item "$script:SourceFolder/Public/*.ps1"
    )

    $moduleScripts |
        Get-Content |
        Add-Content "$OutputDirectory/ChocoCCM/ChocoCCM.psm1"

    $gitversion = gitversion.exe
    $gitversion | Out-String -Width 120 | Write-Host
    $versionInfo = $gitversion | ConvertFrom-Json
    $manifestUpdates = @{
        Path          = $manifest.FullName
        ModuleVersion = $versionInfo.MajorMinorPatch
    }

    $prerelease = $versionInfo.PreReleaseLabel -replace '-'
    if ($prerelease) {
        if ($prerelease -notmatch '^(alpha|beta)') {
            $prerelease = "alpha$prerelease"
        }

        $manifestUpdates.Prerelease = $prerelease
        $script:IsPrerelease = $true
    }

    $script:BuildVersion = if ($prerelease) {
        "$($versionInfo.MajorMinorPatch)-$prerelease"
    }
    else {
        $versionInfo.MajorMinorPatch
    }

    Update-ModuleManifest @manifestUpdates
}

task ImportChecks -After Build {
    $publicFunctions = Get-Item "$script:SourceFolder/Public/*.ps1"

    Import-Module "$OutputDirectory/ChocoCCM" -Force
    $actualFunctions = (Get-Module ChocoCCM).ExportedFunctions
    if ($actualFunctions.Count -lt $publicFunctions.Count) {
        $missingFunctions = $publicFunctions.BaseName | Where-Object { $_ -notin $actualFunctions.Keys }
        $message = @(
            "src/Public: $($publicFunctions.Count) files"
            "ChocoCCM: $($actualFunctions.Count) exported functions"
            "some functions in the Public folder may not be exported"
            "missing functions may include: $($missingFunctions -join ', ')"
        ) -join "`n"
        Write-Warning $message
    }
    elseif ($publicFunctions.Count -lt $actualFunctions.Count) {
        $message = @(
            "src/Public: $($publicFunctions.Count) files"
            "ChocoCCM: $($actualFunctions.Count) exported functions"
            "there seems to be fewer files in the Public folder than public functions exported"
        ) -join "`n"
        Write-Warning $message
    }
}

# Synopsis: CI-specific build operations to run after the normal build
task CIBuild Build, {
    Write-Host $env:GitVersionTool

    Write-Host "##teamcity[buildNumber '$script:BuildVersion']"
}

# Synopsis: run Pester tests
task Test InstallPester, Build, {
    Import-Module Pester -MaximumVersion 4.99

    Copy-Item -Path "$script:SourceFolder/Tests" -Destination "$OutputDirectory/Tests" -Recurse
    $results = Invoke-Pester (Resolve-Path "$OutputDirectory/Tests") -OutputFile "$OutputDirectory/test.results.xml" -OutputFormat NUnitXml -PassThru

    assert ($results.FailedCount -eq 0) "Pester test failures found, see above or the '$OutputDirectory/test.results.xml' result file for details"
}

# Synopsis: generate documentation files
task GenerateDocs {
    & "$PSScriptRoot/mkdocs.ps1"
}

# Synopsis: sign PowerShell scripts
task Sign Build, {
    Write-Host "Signing PSM1 module file"
    $signParams = @{
        CertificateAlgorithm = $CertificateAlgorithm
        TimeStampServer      = $TimeStampServer
        ScriptsToSign        = Get-ChildItem -Path "$OutputDirectory/ChocoCCM" -Recurse -Include '*.ps1', '*.psm1'
    }

    if ($CertificatePath) {
        $signParams.CertificatePath = $CertificatePath
        $signParams.CertificatePassword = $CertificatePassword
    }
    else {
        $signParams.CertificateSubjectName = $CertificateSubjectName
    }

    & "$PSScriptRoot/sign.ps1" @signParams
}

# Synopsis: publish ChocoCCM either internally or to the PSGallery
task Publish -If ($script:ReleaseBuild -or $PublishUrl) Build, {
    if (-not (Test-Path $OutputDirectory)) {
        throw 'Build the module with `Invoke-Build` or `build.ps1` before attempting to publish the module'
    }

    if (-not $NugetApiKey) {
        throw 'Please pass the API key for publishing to the `-NugetApiKey` parameter or set $env:NugetApiKey before publishing'
    }

    $psdFile = Resolve-Path "$OutputDirectory/ChocoCCM"
    $publishParams = @{
        Path        = $psdFile
        NugetApiKey = $NugetApiKey
    }

    if ($PublishUrl) {
        Write-Verbose "Publishing to '$PublishUrl'"
        $repo = Get-PSRepository | Where-Object PublishLocation -EQ $PublishUrl
        if ($repo) {
            $publishParams.Repository = $repo.Name
        }
        else {
            $testRepo = @{
                Name               = 'ChocoCCM'
                SourceLocation     = $PublishUrl
                InstallationPolicy = 'Trusted'
            }

            Register-PSRepositoryFix @testRepo
            $publishParams.Repository = 'ChocoCCM'
        }

        Publish-Module @publishParams
    }

    if ($script:ReleaseBuild) {
        Write-Verbose "Publishing to PSGallery"
        $publishParams.NugetApiKey = $env:POWERSHELLGALLERY_API_KEY
        $publishParams.Repository = 'PSGallery'

        Publish-Module @publishParams
    }
}

# Synopsis: CI configuration; test, build, sign the module, and publish
task CI CIBuild, Sign, Test, Publish

# Synopsis: default task; build and test
task . Build, Test
