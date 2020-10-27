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

        $Test {}

        $Build {

            If (Test-Path $root\Output) {
                
                Remove-Item $root\Output -Recurse -Force

            }

            $null = New-item "$root\Output\ChocoCCM" -ItemType Directory

            Copy-Item "$root\ChocoCCM.psd1" "$root\Output\ChocoCCM"

            Get-ChildItem -Path $root\Public\*.ps1 | Foreach-Object {

                Get-Content $_.FullName | Add-Content "$root\Output\ChocoCCM\ChocoCCM.psm1"

            }

        }

        $TestDeploy {

            if (Test-Path $root\Artifact) {
                Remove-Item $root\Artifact -Recurse -Force
            }

            New-Item $root\Artifact -ItemType Directory

            if ('Artifacts' -notin (Get-PSRepository).Name) {
                $testRepo = @{
                    Name               = 'Artifacts'
                    PublishLocation    = "$(Resolve-Path $root\Artifact)"
                    SourceLocation     = "$(Resolve-Path $root\Output\ChocoCCM)"
                    InstallationPolicy = 'Trusted'
                }

                Register-PSRepository @testRepo

            }

            $psdFile = Resolve-Path "$root\Output\ChocoCCM"
            $publishParams = @{
                Path        = $psdFile
                Repository  = 'Artifacts'
                NugetApiKey = 'FileSystem'
            }

            Publish-Module @publishParams

        }

        $Deploy {

            $psdFile = Resolve-Path "$root\Output\ChocoCCM"
            
            $publishParams = @{
                Path        = $psdFile
                NugetApiKey = $env:Nugetkey
            }

            Publish-Module @publishParams
        }

    }
}