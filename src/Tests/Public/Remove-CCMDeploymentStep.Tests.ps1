Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Remove-CCMDeploymentStep" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            @{
                Id              = "1"
                deploymentSteps = @(
                    @{
                        id   = "2"
                        Name = "Copy Files"
                    }
                    @{
                        id   = "1"
                        Name = "Kill web services"
                    }
                )
            }
        }
    }

    Context "Removing a deployment step" {
        BeforeAll {
            $TestParams = @{
                Deployment = "Deployment Alpha"
                Step       = "Copy Files"
            }

            $Result = Remove-CCMDeploymentStep @TestParams -Confirm:$false
        }

        It "Calls the API to remove the deployment step" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "DELETE" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/Delete" -and
                $Uri.Query -eq "?Id=2" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}