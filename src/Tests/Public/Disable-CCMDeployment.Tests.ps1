Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Disable-CCMDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            @{ Id = $script:TestGuid }
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
    }

    Context "Disabling a deployment" {
        BeforeAll {
            $script:TestGuid = "$(New-Guid)"
            $TestParams = @{
                Deployment = "Your Deployment"
            }

            $Result = Disable-CCMDeployment @TestParams -Confirm:$false
        }

        It "Calls the API to disable the deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/Archive" -and
                $ContentType -eq "application/json" -and
                $Body.id -eq $script:TestGuid
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Disabling a non-existent deployment" -Skip {
        BeforeAll {
            Mock Get-CCMDeployment -ModuleName ChocoCCM {
                throw [Microsoft.PowerShell.Commands.HttpResponseException]::new("Response status code does not indicate success: 400 (Bad Request).")
            }
            Mock Invoke-RestMethod -ModuleName ChocoCCM {
                throw [System.Management.Automation.RuntimeException]::new("Response status code does not indicate success: 400 (Bad Request).")
            }
        }

        It "Throws an error when the deployment doesn't exist" {
            { Disable-CCMDeployment @TestParams -Confirm:$false } | Should -Throw
        }
    }

    Context "Failing to disable a deployment" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM {
                throw [System.Management.Automation.RuntimeException]::new("Response status code does not indicate success: 400 (Bad Request).")
            }
        }

        It "Throws an error when the API call fails" {
            { Disable-CCMDeployment @TestParams -Confirm:$false } | Should -Throw
        }
    }
}