Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Start-CCMDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            @{
                Id   = "$($Name)ID"
                Name = $Name
            }
        }
    }

    Context "Starting a deployment" {
        BeforeAll {
            $TestParams = @{
                Deployment = "Complex Deployment"
            }

            $Result = Start-CCMDeployment @TestParams
        }

        It "Gets the deployment ID from Get-CCMDeployment" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Calls the API to start the deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/Start" -and
                $ContentType -eq "application/json" -and
                $Body.id -eq "$($TestParams.Deployment)ID"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}