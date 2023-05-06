Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "New-CCMDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Method -eq "POST" -and
            $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/CreateOrEdit"
        } {
            @{
                result = @{
                    id = $script:GuidUnderTest
                }
            }
        }
    }

    Context "Creating a new deployment" {
        BeforeAll {
            $script:GuidUnderTest = "$(New-Guid)"
            $TestParams = @{
                Name = "$(New-Guid)"
            }

            $Result = New-CCMDeployment @TestParams
        }

        It "Calls the API to create a new deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name
            }
        }

        It "Returns Nothing" {
            $Result.name | Should -Be $TestParams.Name

            # This should be returned by the request to DeploymentPlans/CreateOrEdit
            $Result.id | Should -Be $script:GuidUnderTest
        }
    }
}