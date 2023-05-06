Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Import-PDQDeployPackage" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock New-CCMDeployment -ModuleName ChocoCCM
        Mock New-CCMDeploymentStep -ModuleName ChocoCCM
    }

    # Skipping: I need an example of the XML file.
    Context "Importing an Example Package" -Skip {
        BeforeAll {
            New-Item -Path $TestDrive -Name "ExamplePackage.xml" -Value @"
<xml></xml>
"@
            $TestParams = @{
                PdqXml = "$TestDrive\ExamplePackage.xml"
            }

            $Result = Import-PDQDeployPackage @TestParams
        }

        It "Creates a new deployment with the name from the package" {
            Should -Invoke New-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq "PDQ Import: Example Package"
            }
        }

        It "Creates a step for each step within the PDQ Deployment" {
            Should -Invoke New-CCMDeploymentStep -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Deployment -eq "PDQ Import: Example Package" -and
                $Name -eq "Install Example Package" -and
                $Type -eq "Basic" -and
                $ValidExitCodes -eq @("0") -and
                $FailOnError -eq $false
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}