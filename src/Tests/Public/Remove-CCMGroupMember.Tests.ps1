Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Remove-CCMGroupMember" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Method -eq "POST" -and
            $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit"
        } {
            @{
                success = $true
            }
        }
        Mock Get-CCMGroupMember -ModuleName ChocoCCM {
            @{
                Id        = 1
                Name      = "TestLab"
                Computers = @(
                    @{
                        computerId = 1
                        name       = "TestPC1"
                    }
                    @{
                        computerId = 2
                        name       = "TestPC2"
                    }
                )
                Groups    = @(
                    @{
                        subGroupId = 3
                        name       = "FirstLab"
                    }
                    @{
                        subGroupId = 4
                        name       = "SecondLab"
                    }
                )
            }
        }
        Mock Get-CCMComputer -ModuleName ChocoCCM {
            @{
                Id   = 1
                Name = "TestPC1"
            }
            @{
                Id   = 2
                Name = "TestPC2"
            }
            @{
                Id   = 3
                Name = "Test1"
            }
            @{
                Id   = 4
                Name = "Test2"
            }
        }
        Mock Get-CCMGroup -ModuleName ChocoCCM
    }

    Context "Removing a computer from a group" {
        BeforeAll {
            $TestParams = @{
                Group          = "TestLab"
                ComputerMember = "TestPC1"
            }

            $Result = Remove-CCMGroupMember @TestParams
        }

        It "Calls the API to update the group object" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Computers.name -eq @("TestPC2") -and
                "$($Body.Groups.name)" -eq "FirstLab SecondLab"
            }
        }

        # TODO: This seems broken, but I'm not yet sure why. Returns [system.string[]] as if cast to string.
        It "Returns an updated object representing the group" -Skip {
            $Result | Should -Be [PSCustomObject]@ {
                Status            = $true
                group             = $TestParams.Group
                AffectedComputers = $TestParams.ComputerMember
                AffectedGroups    = $null
            }
        }
    }
}