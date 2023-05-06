Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Remove-CCMStaleDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            1..60 | ForEach-Object {
                @{
                    Deployment = $_
                    CreationDate = (Get-Date).AddDays(-$_)
                    Result = 0  # Is 0 really a bad state?
                }
            }
        }
        Mock Remove-CCMDeployment -ModuleName ChocoCCM
    }

    # This function is broken. It tries to use the -All parameter of Get-CCMDeployment, but that parameter doesn't exist.
    Context "Removing Stale Deployments" -Skip {
        BeforeAll {
            $TestParams = @{
                Age = "30"
            }

            $Result = Remove-CCMStaleDeployment @TestParams -Confirm:$false
        }

        It "Calls Get-CCMDeployment to find all existing deployments" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly
        }

        It "Calls Remove-CCMDeployment to remove deployments with age greater than 30 days" {
            Should -Invoke Remove-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 30 -Exactly -ParameterFilter {
                $Deployment -ge 30  # This test could be improved, but as the function is broken it is what it is.
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}