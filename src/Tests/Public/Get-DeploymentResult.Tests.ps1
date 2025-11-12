Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-DeploymentResult" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            @{Id = 13 }
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/GetAllPagedByDeploymentPlanId"
        } {
            @{
                result = @{
                    items = @(
                        @{
                            id   = 13
                            name = "Google Chrome Upgrade"
                        }
                    )
                }
            }
        }
    }

    Context "Getting a deployment result" {
        BeforeAll {
            $TestParams = @{
                Deployment = "Google Chrome Upgrade"
            }

            $Result = Get-DeploymentResult @TestParams
        }

        It "Retrieves the deployment ID for the requested Deployment Name" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Calls the API to retrieve the deployment result based on the ID" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/GetAllPagedByDeploymentPlanId" -and
                $ContentType -eq "application/json" -and
                $Uri.Query -match "deploymentPlanId=13"
            }
        }

        It "Returns the result items" {
            $Result.name | Should -Be "Google Chrome Upgrade"
        }
    }
}