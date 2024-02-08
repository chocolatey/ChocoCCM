Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMRole" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -MockWith {
            @{
                result = @{
                    items = @(
                        @{
                            name = "CCMAdmin"
                            id   = 1
                        }
                        @{
                            name = "CCMUser"
                            id   = 2
                        }
                    )
                }
            }
        }
    }

    Context "Getting a specific CCM Role" {
        BeforeAll {
            $TestValues = @{
                Name = "CCMAdmin"
            }

            $Result = Get-CCMRole @TestValues
        }

        It "Calls the API to get roles" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Role/GetRoles" -and
                $Uri.Query -eq "?permission=" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns the correct role" {
            $Result.Name | Should -Be $TestValues.Name
            $Result | Should -HaveCount 1
        }
    }

    Context "Getting a non-existent CCM Role" {
        BeforeAll {
            $TestValues = @{
                Name = "OtherAdmin"
            }

            $Result = Get-CCMRole @TestValues
        }

        It "Calls the API to get roles" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Role/GetRoles" -and
                $Uri.Query -eq "?permission=" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
    Context "Getting all CCM Roles" {
        BeforeAll {
            $Result = Get-CCMRole
        }

        It "Calls the API to get roles" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Role/GetRoles" -and
                $Uri.Query -eq "?permission=" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns All Returned Roles" {
            $Result | Should -HaveCount 2
        }
    }

    Context "Failing to get a specified role" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM -MockWith {
                throw [System.Net.WebException]::new("Failed")
            }
        }

        It "Throws an exception when failing to get a specified role" {
            { Get-CCMRole -Name "CCMBadmin" } | Should -Throw "Failed"
        }
    }
}