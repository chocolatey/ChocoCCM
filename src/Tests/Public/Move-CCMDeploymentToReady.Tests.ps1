Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Move-CCMDeploymentToReady" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            @{Id = $script:IdUnderTest }
        }
    }

    Context "Moving a depoloyment to Ready" {
        BeforeAll {
            $script:IdUnderTest = Get-Random -Minimum 1 -Maximum 100
            $TestParams = @{
                Deployment = "Complex Deployment"
            }

            $Result = Move-CCMDeploymentToReady @TestParams
        }

        It "Retrieves the deployment ID for the requested Deployment Name" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Calls the API to move the returned ID to Ready" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/MoveToReady" -and
                $ContentType -eq "application/json" -and
                $Body.id -eq $script:IdUnderTest
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Failing to move a deployment step to ready" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM {
                throw [webexception]::new("The remote server returned an error: (500) Internal Server Error.")
            }

            $TestParams = @{
                Deployment = "Complex Deployment"
            }
        }

        It "Throws an error when failing to move a deployment step to ready" {
            { Move-CCMDeploymentToReady @TestParams } | Should -Throw
        }
    }
}