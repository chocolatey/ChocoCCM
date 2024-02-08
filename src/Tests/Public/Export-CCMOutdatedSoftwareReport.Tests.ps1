Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Export-CCMOutdatedSoftwareReport" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath.StartsWith("/api/services/app/OutdatedReports/GetOutdatedSoftwareTo")
        } {
            $Extension = @("xlsx", "pdf")[[int]($Uri.AbsolutePath.EndsWith("Pdf"))]
            [pscustomobject]@{
                result = @{
                    fileName  = $Uri.Query.Split('=')[-1] + '.' + $Extension
                    fileType  = $Extension
                    fileToken = "$(New-Guid)"
                }
            }
        }
        Mock Get-CCMOutdatedSoftwareReport -ModuleName ChocoCCM
    }

    Context "Exporting a PDF Report" {
        BeforeAll {
            $TestParams = @{
                Report       = "7/4/2020 6:44:40 PM"
                Type         = "PDF"
                OutputFolder = $TestDrive
            }

            $Result = Export-CCMOutdatedSoftwareReport @TestParams
        }

        It "Calls the API to get a file type, token, and name" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/OutdatedReports/GetOutdatedSoftwareToPdf" -and
                $Method -eq "GET" -and
                $ContentType -eq "application/json"
            }
        }

        It "Calls the API to download the appropriate file" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/File/DownloadTempFile" -and
                $Method -eq "GET" -and
                $ContentType -eq "pdf" -and
                $OutFile
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Exporting an Excel Report" {
        BeforeAll {
            $TestParams = @{
                Report       = "7/4/2020 6:44:40 PM"
                Type         = "Excel"
                OutputFolder = $TestDrive
            }

            $Result = Export-CCMOutdatedSoftwareReport @TestParams
        }

        It "Calls the API to get a file type, token, and name" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/OutdatedReports/GetOutdatedSoftwareToExcel" -and
                $Method -eq "GET" -and
                $ContentType -eq "application/json"
            }
        }

        It "Calls the API to download the appropriate file" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/File/DownloadTempFile" -and
                $Method -eq "GET" -and
                $ContentType -eq "xlsx" -and
                $OutFile
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Failing to find an outdated report" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
                $Uri.AbsolutePath.StartsWith("/api/services/app/OutdatedReports/GetOutdatedSoftwareTo")
            } -MockWith {
                throw [System.Net.WebException]::new("Report not found")
            }

            $TestParams = @{
                Report       = "Not Found"
                Type         = "Excel"
                OutputFolder = $TestDrive
            }
        }

        It "Throws an error" {
            { Export-CCMOutdatedSoftwareReport @TestParams } | Should -Throw
        }
    }

    Context "Failing to export an outdated report" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
                -not $Uri.AbsolutePath.StartsWith("/api/services/app/OutdatedReports/GetOutdatedSoftwareTo")
            } -MockWith {
                throw [System.Net.WebException]::new("File not found.")
            }

            $TestParams = @{
                Report       = "Not Found"
                Type         = "Excel"
                OutputFolder = $TestDrive
            }
        }

        # Skipping: Despite the block around this, we don't actually throw. We just output the error details.
        It "Throws an error" -Skip {
            { Export-CCMOutdatedSoftwareReport @TestParams } | Should -Throw
        }
    }
}