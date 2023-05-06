Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMOutdatedSoftwareReport" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/Reports/GetAllPaged"
        } {
            @{
                result = @{
                    items = @(
                        1..3 | ForEach-Object {
                            @{
                                reportType   = "OutdatedSoftware"
                                creationTime = "$(Get-Date)"
                                id           = "$(New-Guid)"
                            }
                        }
                    )
                }
            }
        }
    }

    Context "Getting an outdated report (that is actually up to date)" {
        BeforeAll {
            $Result = Get-CCMOutdatedSoftwareReport
        }

        It "Calls the API to get all existing reports" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Reports/GetAllPaged" -and
                $Uri.Query -eq "?reportTypeFilter=1" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns all report objects" {
            # Is this the correct behaviour? Check on ReportTypeFilter=1
            $Result | Should -HaveCount 3
        }
    }

    Context "Failing to get all reports" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Reports/GetAllPaged"
            } -MockWith {
                throw [System.Net.WebException]::new("Failed")
            }
        }

        It "Throws an exception when failing to get all reports" {
            { Get-CCMOutdatedSoftwareReport } | Should -Throw "Failed"
        }
    }
}