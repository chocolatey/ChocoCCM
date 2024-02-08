Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Set-CCMNotificationStatus" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
    }

    Context "Setting notification On" {
        BeforeAll {
            $TestParams = @{
                Enable = $true
            }

            $Result = Set-CCMNotificationStatus @TestParams
        }

        It "Calls the API to set the notification status" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "PUT" -and
                $Uri.AbsolutePath -eq "/api/services/app/Notification/UpdateNotificationSettings" -and
                $ContentType -eq "application/json" -and
                $Body.receiveNotifications -eq $true -and
                $Body.notifications.name -eq "App.NewUserRegistered" -and
                $Body.notifications.isSubscribed -eq $true
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Setting notification Off" {
        BeforeAll {
            $TestParams = @{
                Disable = $true
            }

            $Result = Set-CCMNotificationStatus @TestParams
        }

        It "Calls the API to set the notification status" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "PUT" -and
                $Uri.AbsolutePath -eq "/api/services/app/Notification/UpdateNotificationSettings" -and
                $ContentType -eq "application/json" -and
                $Body.receiveNotifications -eq $false -and
                $Body.notifications.name -eq "App.NewUserRegistered" -and
                $Body.notifications.isSubscribed -eq $true
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}