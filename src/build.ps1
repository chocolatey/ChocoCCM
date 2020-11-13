[cmdletBinding()]
Param(
    [Parameter()]
    [Switch]
    $Test,

    [Parameter()]
    [Switch]
    $Build,

    [Parameter()]
    [Switch]
    $Deploy,

    [Parameter()]
    [Switch]
    $TestDeploy
)



process {
    $root = Split-Path -Parent $MyInvocation.MyCommand.Definition

    Switch ($true) {

        $Test {
            Install-Module Pester -MaximumVersion 4.99 -SkipPublisherCheck -Force
            Import-Module Pester
            Invoke-Pester (Resolve-Path "$root\Tests") -OutputFile "$($env:Build_ArtifactStagingDirectory)\test.results.xml" -OutputFormat NUnitXml
        }

        $Build {

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

        }

        $TestDeploy {

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

        $Deploy {

            $psdFile = Resolve-Path "$root\Output\ChocoCCM"
            
            $publishParams = @{
                Path        = $psdFile
                NugetApiKey = $env:NugetApiKey
            }

            Publish-Module @publishParams
        }

    }
}