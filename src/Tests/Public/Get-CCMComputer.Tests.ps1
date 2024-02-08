Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMComputer" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/Computers/GetAll"
        } {
            @{
                result =  1..20 | ForEach-Object {
                    [PSCustomObject]@{
                        name = "Computer $_"
                    }
                }
            }
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/Computers/GetComputerForEdit"
        } {
            @{
                computerGuid = "$(New-Guid)"
                name         = "Computer $($Uri.Query.Split('=')[-1])"
                id           = $Uri.Query.Split('=')[-1]
            }
        }
    }

    Context "Getting all computers" {
        BeforeAll {
            $Result = Get-CCMComputer
        }

        It "Calls the API to get all computers" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Computers/GetAll"
            }
        }

        It "Returns All Computers" {
            $Result | Should -HaveCount 20
        }
    }

    Context "Getting a computer by Name" {
        BeforeAll {
            $TestParams = @{
                Computer = "Computer $(Get-Random -Minimum 1 -Maximum 10)"
            }
            $Result = Get-CCMComputer @TestParams
        }

        It "Calls the API to get all computers" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Computers/GetAll"
            }
        }

        It "Returns the computer requested" {
            $Result | Should -HaveCount 1
            $Result.name | Should -Be $TestParams.Computer
        }
    }

    Context "Getting computers by Name" {
        BeforeAll {
            $TestParams = @{
                Computer = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Computer $($_)" }
            }
            $Result = Get-CCMComputer @TestParams
        }

        It "Calls the API to get all computers" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Computers/GetAll"
            }
        }

        It "Returns the computer requested" {
            $Result | Should -HaveCount $TestParams.Computer.Count
            $Result.name | Should -Be $TestParams.Computer
        }
    }

    Context "Getting a computer by ID" {
        BeforeAll {
            $TestParams = @{
                ID = Get-Random -Minimum 1 -Maximum 10
            }
            $Result = Get-CCMComputer @TestParams
        }

        It "Doesn't call the API to get all computers" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Computers/GetAll"
            }
        }

        It "Calls the API to get the exact computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Computers/GetComputerForEdit" -and
                $Uri.Query.EndsWith($TestParams.ID)
            }
        }

        It "Returns the computer requested" {
            $Result | Should -HaveCount 1
            $Result.name | Should -Be "Computer $($TestParams.ID)"
        }
    }
}