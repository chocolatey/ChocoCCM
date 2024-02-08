Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Remove-CCMDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM { @{Id = $script:IDUnderTest } }
    }

    Context "Removing a deployment" {
        BeforeAll {
            $TestParams = @{
                Deployment = "Super Complex Deployment"
            }

            $Result = Remove-CCMDeployment @TestParams -Confirm:$false
        }

        It "Gets the ID for the deployment to delete" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Calls the API to delete the deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "DELETE" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/Delete" -and
                $Uri.Query -eq "?Id=$($script:IDUnderTest)" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Removing multiple deployments" {
        BeforeAll {
            $TestParams = @{
                Deployment = @(
                    "Super Complex Deployment"
                    "Deployment Alpha"
                )
            }

            $Result = Remove-CCMDeployment @TestParams -Confirm:$false
        }

        It "Gets the ID for the deployment to delete" {
            foreach ($Deployment in $TestParams.Deployment) {
                Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                    $Name -eq $Deployment
                }
            }
        }

        It "Calls the API to delete each deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times $TestParams.Deployment.Count -Exactly -ParameterFilter {
                $Method -eq "DELETE" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/Delete" -and
                $Uri.Query -eq "?Id=$($script:IDUnderTest)" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}