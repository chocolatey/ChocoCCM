Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMOutdatedSoftwareReportDetail" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMOutdatedSoftwareReport -ModuleName ChocoCCM {
            @(
                @{
                    reportType   = "OutdatedSoftware"
                    creationTime = "7/4/2020 6:44:40 PM"
                    id           = $script:TestGuid
                }
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

    Context "Getting a specific Outdated Software Report" {
        BeforeAll {
            $script:TestGuid = "$(New-Guid)"
            $TestParams = @{
                Report = "7/4/2020 6:44:40 PM"
            }

            $Result = Get-CCMOutdatedSoftwareReportDetail @TestParams
        }

        It "Calls Get-CCMOutdatedSoftwareReport to get the report ID" {
            Should -Invoke Get-CCMOutdatedSoftwareReport -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly
        }

        It "Calls the API to get the report details" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/OutdatedReports/GetAllByReportId" -and
                $Uri.Query -match "reportId=$($script:TestGuid)" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns the requested result" {
            $Result | Should -BeNullOrEmpty
        }
    }
}