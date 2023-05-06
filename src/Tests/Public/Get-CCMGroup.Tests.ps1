Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMGroup" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath.EndsWith("GetAll")
        } {
            @{
                result = 1..10 | ForEach-Object {
                    @{
                        id   = $_
                        name = "Group $_"
                    }
                }
            }
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath.EndsWith("GetGroupForEdit")
        } {
            @{
                result = @{
                    id   = $Uri.Query.Split('=')[1]
                    name = "Group $($Uri.Query.Split('=')[1])"
                }
            }
        }
    }

    Context "Getting all groups" {
        BeforeAll {
            $Result = Get-CCMGroup
        }

        It "Calls the API to get all groups" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/GetAll"
            }
        }

        It "Returns all groups" {
            $Result | Should -HaveCount 10
        }
    }

    Context "Getting a group by ID" {
        BeforeAll {
            $TestParams = @{
                Id = "1"
            }

            $Result = Get-CCMGroup @TestParams
        }

        It "Does not call the API to get all groups" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/GetAll"
            }
        }

        It "Calls the API to get the exact group requested" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Groups/GetGroupForEdit" -and
                $Uri.Query -eq "?Id=$($TestParams.Id)"
            }
        }

        It "Returns the requested group" {
            $Result | Should -HaveCount 1
            $Result.Id | Should -Be $TestParams.Id
            $Result.Name | Should -Be "Group $($TestParams.Id)"
        }
    }

    Context "Getting a group by name" {
        BeforeAll {
            $TestParams = @{
                Group = "Group $(Get-Random -Minimum 1 -Maximum 10)"
            }

            $Result = Get-CCMGroup @TestParams
        }

        It "Calls the API to get all groups" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/GetAll"
            }
        }

        It "Returns the correct group" {
            $Result.name | Should -Be $TestParams.Group
        }
    }

    # These two appear to not work well, and should probably be rewritten or removed from the functionality
    Context "Getting multiple groups by name" -Skip {
        BeforeAll {
            $TestParams = @{
                Group = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Group $($_)" } | Sort-Object { [int]($_.Split(' ')[-1]) }
            }

            $Result = Get-CCMGroup @TestParams
        }

        It "Calls the API to get all groups" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/GetAll"
            }
        }

        It "Returns the correct groups" {
            $Result.Name | Sort-Object { [int]($_.Split(' ')[-1]) } | Should -Be $TestParams.Group
            $Results.Name | Should -HaveCount $TestParams.Group.Count
        }
    }


    # Getting multiple groups by ID is very likely to fail badly, as there's no handling for [string[]]
    Context "Getting multiple groups by ID" -Skip {
        BeforeAll {
            $TestParams = @{
                Id = "1", "2", "3"
            }

            $Result = Get-CCMGroup @TestParams
        }

        It "Does not call the API to get all groups" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/GetAll"
            }
        }

        It "Calls the API to get the exact group requested once per group requested" {
            foreach ($Id in $TestParams.Id) {
                Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                    $Uri.AbsolutePath -eq "/api/services/app/Groups/GetGroupForEdit" -and
                    $Uri.Query -eq "?Id=$($Id)"
                }
            }
        }

        It "Should absolutely not call the API to get the exact group requested once with all the IDs concatenated" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Groups/GetGroupForEdit" -and
                $Uri.Query -eq "?Id=$($TestParams.Id -join '%20')"
            }
        }

        It "Returns the requested group" {
            $Result | Should -HaveCount $TestParams.Id.Count
            $Result.Id | Should -Be $TestParams.Id
        }
    }
}