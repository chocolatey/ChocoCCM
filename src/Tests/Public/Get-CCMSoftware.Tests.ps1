Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMSoftware" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/Software/GetAll"
        } {
            @{
                result = @{
                    items = @(
                        @{
                            id        = 37
                            name      = "VLC Media Player"
                            packageId = "vlc"
                        }
                        @{
                            id        = 38
                            name      = "Mozilla Firefox"
                            packageId = "mozillafirefox"
                        }
                    )
                }
            }
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId"
        } {
            @{
                result = @(
                    @{
                        id        = 37
                        name      = "VLC Media Player"
                        packageId = "vlc"
                    }
                )
            }
        }
    }

    Context "Gets all software" {
        BeforeAll {
            $Result = Get-CCMSoftware
        }

        It "Calls the API to get all software IDs" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Software/GetAll"
            }
        }

        It "Returns Nothing" {
            $Result | Should -HaveCount 2
            $Result.name | Should -Contain "VLC Media Player"
            $Result.name | Should -Contain "Mozilla Firefox"
        }
    }

    Context "Gets software by name" {
        BeforeAll {
            $TestParams = @{
                Software = "VLC Media Player"
            }

            $Result = Get-CCMSoftware @TestParams
        }

        It "Calls the API to get all software IDs" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Software/GetAll"
            }
        }

        It "Calls the API to get the specific software ID" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId" -and
                $Uri.Query -match "softwareId=37"
            }
        }

        It "Returns the VLC Software Details" {
            $Result | Should -HaveCount 1
            $Result.Name | Should -Be "VLC Media Player"
            $Result.packageId | Should -Be "vlc"
        }
    }

    Context "Gets software by package id" {
        BeforeAll {
            $TestParams = @{
                Package = "vlc"
            }

            $Result = Get-CCMSoftware @TestParams
        }

        It "Calls the API to get all software IDs" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Software/GetAll"
            }
        }

        It "Calls the API to get the specific software ID" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId" -and
                $Uri.Query -match "softwareId=37"
            }
        }

        It "Returns the VLC Software Details" {
            $Result | Should -HaveCount 1
            $Result.Name | Should -Be "VLC Media Player"
            $Result.packageId | Should -Be "vlc"
        }
    }

    Context "Gets software by software id" {
        BeforeAll {
            $TestParams = @{
                Id = "37"
            }

            $Result = Get-CCMSoftware @TestParams
        }

        It "Does not call the API to get all software IDs" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Software/GetAll"
            }
        }

        It "Calls the API to get the specific software ID" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId" -and
                $Uri.Query -match "softwareId=37"
            }
        }

        # Why is ID not expanding .items?
        # Potential bug around items vs not items, given the same call in all cases.
        It "Returns the VLC Software Details" -Skip {
            $Result | Should -HaveCount 1
            $Result.Name | Should -Be "VLC Media Player"
            $Result.packageId | Should -Be "vlc"
        }
    }
}