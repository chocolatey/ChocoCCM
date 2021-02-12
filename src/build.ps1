[CmdletBinding()]
Param(
    [Parameter()]
    [String]
    $Step
)


$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

Switch ($Step) {
        
    'GitVersion' {

        $DotNetChannel = "Current";
        $DotNetVersion = "2.2.401";
        $DotNetInstallerUri = "https://dot.net/v1/dotnet-install.ps1";

        ###########################################################################
        # INSTALL .NET CORE CLI
        ###########################################################################

        Function Remove-PathVariable([string]$VariableToRemove) {
            $path = [Environment]::GetEnvironmentVariable("PATH", "User")
            if ($path -ne $null) {
                $newItems = $path.Split(';', [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
                [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join(';', $newItems), "User")
            }

            $path = [Environment]::GetEnvironmentVariable("PATH", "Process")
            if ($path -ne $null) {
                $newItems = $path.Split(';', [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
                [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join(';', $newItems), "Process")
            }
        }

        # Get .NET Core CLI path if installed.
        $FoundDotNetCliVersion = $null;
        if (Get-Command dotnet -ErrorAction SilentlyContinue) {
            $FoundDotNetCliVersion = dotnet --version;
        }

        if ($FoundDotNetCliVersion -ne $DotNetVersion) {
            $InstallPath = Join-Path $PSScriptRoot ".dotnet"
            if (!(Test-Path $InstallPath)) {
                mkdir -Force $InstallPath | Out-Null;
            }
            (New-Object System.Net.WebClient).DownloadFile($DotNetInstallerUri, "$InstallPath\dotnet-install.ps1");
            & $InstallPath\dotnet-install.ps1 -Channel $DotNetChannel -Version $DotNetVersion -InstallDir $InstallPath;

            Remove-PathVariable "$InstallPath"
            $env:PATH = "$InstallPath;$env:PATH"
        }

        $env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 1
        $env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

            
        Write-Host "Download GitVersion to build directory"
        $dotnetArgs = @('tool', 'install', 'gitversion.tool', "--version 5.6.6", "--tool-path $root")
        & dotnet @dotnetArgs

        $GitVersionTool = (Get-ChildItem $root -Recurse -Filter "dotnet-gitversion*").FullName
        Write-Host $GitVersionTool
        Write-Output "##teamcity[setParameter name='env.GitVersionTool' value='$GitVersionTool']"
    }

    'Test' {
        Install-Module Pester -MaximumVersion 4.99 -SkipPublisherCheck -Force
        Import-Module Pester
        Invoke-Pester (Resolve-Path "$root\Tests") -OutputFile "$($env:Build_ArtifactStagingDirectory)\test.results.xml" -OutputFormat NUnitXml
    }

    'Build' {

        If (Test-Path $root\Output) {
                
            Remove-Item $root\Output -Recurse -Force

        }

        $null = New-item "$root\Output\ChocoCCM" -ItemType Directory

        Copy-Item "$root\ChocoCCM.psd1" "$root\Output\ChocoCCM"

        $string = @'
if(-not (Test-Path $env:ChocolateyInstall\license\chocolatey.license.xml)){
    throw "A licensed version of Chocolatey For Business is required to import and use this module"
}

'@

        $string | Add-Content "$root\Output\ChocoCCM\ChocoCCM.psm1"

        Get-ChildItem -Path $root\Public\*.ps1 | Foreach-Object {

            Get-Content $_.FullName | Add-Content "$root\Output\ChocoCCM\ChocoCCM.psm1"

        }

        Write-Host $env:GitVersionTool

    }

    'BuildLocal' {
        If (Test-Path $root\Output) {
                
            Remove-Item $root\Output -Recurse -Force

        }

        $null = New-item "$root\Output\ChocoCCM" -ItemType Directory

        Copy-Item "$root\ChocoCCM.psd1" "$root\Output\ChocoCCM"

        $string = @'
if(-not $IsMacOS){
    if(-not (Test-Path $env:ChocolateyInstall\license\chocolatey.license.xml)){
        throw "A licensed version of Chocolatey For Business is required to import and use this module"
    }
}

'@

        $string | Add-Content "$root\Output\ChocoCCM\ChocoCCM.psm1"

        Get-ChildItem -Path $root\Public\*.ps1 | Foreach-Object {

            Get-Content $_.FullName | Add-Content "$root\Output\ChocoCCM\ChocoCCM.psm1"

        }
    }

    'TestDeploy' {

        if (Test-Path $root\Artifact) {
            Remove-Item $root\Artifact -Recurse -Force
        }

        New-Item $root\Artifact -ItemType Directory

        if ('ChocoCCM' -notin (Get-PSRepository).Name) {
            $testRepo = @{
                Name               = 'ChocoCCM'
                PublishLocation    = "$env:RepoUrl"
                SourceLocation     = "$env:RepoUrl"
                InstallationPolicy = 'Trusted'
            }

            Register-PSRepository @testRepo

        }

        $psdFile = Resolve-Path "$root\Output\ChocoCCM"
        $publishParams = @{
            Path        = $psdFile
            Repository  = 'ChocoCCM'
            NugetApiKey = '$env:NugetApiKey'
        }

        Publish-Module @publishParams

    }

    'Deploy' {

        $psdFile = Resolve-Path "$root\Output\ChocoCCM"
            
        $publishParams = @{
            Path        = $psdFile
            NugetApiKey = $env:NugetApiKey
        }

        Publish-Module @publishParams
    }

    default {
        write-output "bob was here"
    }

}

