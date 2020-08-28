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
    $Deploy
)



process {

    Switch($true){

        $Test {}
        $Build {
            $root = Split-Path -Parent $MyInvocation.MyCommand.Definition

            If(Test-Path $root\Output){
                
                Remove-Item $root\Output -Recurse -Force

            }

            $null = New-item "$root\Output\ChocoCCM" -ItemType Directory

            Copy-Item "$root\ChocoCCM.psd1" "$root\Output\ChocoCCM"

            Get-ChildItem -Path $root\Public\*.ps1 | Foreach-Object {

                Get-Content $_.FullName | Add-Content "$root\Output\ChocoCCM\ChocoCCM.psm1"

            }

        }

        $Deploy {}

    }
}