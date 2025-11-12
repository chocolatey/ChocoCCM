Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMOutdatedSoftwareMember" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMSoftware -ModuleName ChocoCCM -MockWith {
            @(1..3 | ForEach-Object { @{softwareId = $_ } })
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId"
        } {
            if ($Uri.Query -match "softwareId=(?<SoftwareId>\d+)") {
                $SoftwareId = $Matches.SoftwareId
            }
            @{
                result = @{
                    items = foreach ($ComputerId in 1..4) {
                        @{
                            softwareId = $SoftwareId
                            software   = @{
                                name           = "VLC Media Player"
                                packageId      = $SoftwareId
                                packageVersion = "1.0.$($SoftwareId)"
                            }
                            computer   = @{
                                name         = "Computer$($ComputerId)"
                                friendlyName = "Computer $($ComputerId)"
                                ipaddress    = "10.0.0.$($ComputerId)"
                                fqdn         = "computer$($ComputerId).local"
                                computerid   = "$(New-Guid)"
                            }
                        }
                    }
                }
            }
        }
    }

    Context "Getting computers that have the specified software installed and requiring an update, using the software name" {
        BeforeAll {
            $TestParams = @{
                Software = "VLC Media Player"
            }

            $Result = Get-CCMOutdatedSoftwareMember @TestParams
        }

        # It does seem that this will only ever get the first 100 results per piece of software
        It "Calls the API to get computers with the specified software installed" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 3 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId" -and
                $Uri.Query -match "softwareId=(1|2|3)"
            }
        }

        It "Returns a record per outdated-software-per-computer combination" {
            $Result | Should -HaveCount 12
        }
    }

    Context "Getting computers that have the specified software installed and requiring an update, using the package id" {
        BeforeAll {
            $TestParams = @{
                Package = "vlc"
            }

            $Result = Get-CCMOutdatedSoftwareMember @TestParams
        }

        # It does seem that this will only ever get the first 100 results per piece of software
        It "Calls the API to get computers with the specified software installed" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 3 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId" -and
                $Uri.Query -match "softwareId=(1|2|3)"
            }
        }

        It "Returns a record per outdated-software-per-computer combination" {
            $Result | Should -HaveCount 12
        }
    }

    Context "Failing to return installs of the specified software" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM {
                throw [System.Net.WebException]::new("Failed to get software")
            }
        }

        # Skipping: Again, we are simply returning the exception message to output, polluting the output
        It "Throws an exception" -Skip {
            { Get-CCMOutdatedSoftwareMember -Software "vlc" } | Should -Throw
        }
    }
}