Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Remove-CCMGroup" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMGroup -ModuleName ChocoCCM {
            @{
                Id = "$($Group)ID"
            }
        }
    }

    Context "Removing a group" {
        BeforeAll {
            $TestParams = @{
                Group = "WebServers"
            }

            $Result = Remove-CCMGroup @TestParams -Confirm:$false
        }

        It "Calls Get-CCMGroup to get the ID for the group" {
            Should -Invoke Get-CCMGroup -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Group -eq $TestParams.Group
            }
        }

        It "Calls the API to remove the group" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "DELETE" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/Delete" -and
                $Uri.Query -eq "?id=$($TestParams.Group)ID" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Removing multiple groups" {
        BeforeAll {
            $TestParams = @{
                Group = "WebServers", "TestAppDeployment"
            }

            $Result = Remove-CCMGroup @TestParams -Confirm:$false
        }

        It "Calls Get-CCMGroup to get the ID for the group" {
            foreach ($GroupName in $TestParams.Group) {
                Should -Invoke Get-CCMGroup -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                    $Group -eq $GroupName
                }
            }
        }

        It "Calls the API to remove the group" {
            foreach ($GroupName in $TestParams.Group) {
                Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                    $Method -eq "DELETE" -and
                    $Uri.AbsolutePath -eq "/api/services/app/Groups/Delete" -and
                    $Uri.Query -eq "?id=$($GroupName)ID" -and
                    $ContentType -eq "application/json"
                }
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}