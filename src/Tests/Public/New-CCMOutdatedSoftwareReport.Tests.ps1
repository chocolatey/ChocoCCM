Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "New-CCMOutdatedSoftwareReport" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
    }

    Context "Creating a new outdated software report" {
        BeforeAll {
            $Result = New-CCMOutdatedSoftwareReport
        }

        It "Calls the API to create a new outdated report" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/OutdatedReports/Create" -and
                $ContentType -eq "application/json"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}