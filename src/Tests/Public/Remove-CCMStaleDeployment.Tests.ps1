Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Remove-CCMStaleDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-Date -ModuleName ChocoCCM {
            $script:TestDate
        }
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            $script:TestData
        }
        Mock Remove-CCMDeployment -ModuleName ChocoCCM
    }

    Context "Removing Stale Deployments" {
        BeforeAll {
            $TestParams = @{
                Age = "30"
            }

            $script:TestData = 1..100 | ForEach-Object {
                @{
                    Deployment   = $_
                    CreationDate = (Get-Date).AddDays((Get-Random -Minimum (- $TestParams.Age * 2) -Maximum 0))
                    Result       = 0, 1, 2, 8 | Get-Random
                }
            }
            $script:TestDate = Get-Date
            $StaleDeployments = $script:TestData.Where{
                $_.CreationDate -ge $script:TestDate.AddDays(-$TestParams.Age) -and
                $_.Result -ne 1
            }

            $Result = Remove-CCMStaleDeployment @TestParams -Confirm:$false
        }

        It "Calls Get-CCMDeployment to find all existing deployments" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly
        }

        It "Calls Remove-CCMDeployment to remove stale deployments from the last $($TestParams.Age) days" {
            Should -Invoke Remove-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times $StaleDeployments.Count -Exactly
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}