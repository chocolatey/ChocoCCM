Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMOutdatedSoftware" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Get-CCMSoftware -ModuleName ChocoCCM -MockWith {
            @(
                @{
                    id         = 1
                    name       = "Software 1"
                    version    = "1.0.0"
                    isOutdated = $true
                },
                @{
                    id         = 2
                    name       = "Software 2"
                    version    = "1.0.0"
                    isOutdated = $false
                },
                @{
                    id         = 3
                    name       = "Software 3"
                    version    = "1.0.0"
                    isOutdated = $true
                }
            )
        }
    }

    Context "Getting Outdated Software" {
        BeforeAll {
            $Result = Get-CCMOutdatedSoftware
        }

        It "Calls Get-CCMSoftware" {
            Should -Invoke Get-CCMSoftware -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly
        }

        It "Returns only software where isOutdated is true" {
            $Result.isOutdated | Should -Not -Contain $false
        }
    }
}