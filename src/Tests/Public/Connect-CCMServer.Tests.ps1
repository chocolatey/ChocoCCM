Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Connect-CCMServer" {
    BeforeAll {
        Mock Invoke-WebRequest -ModuleName ChocoCCM -MockWith {
            if ($SessionVariable -eq "Session") {
                $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            }
        }
    }

    Context "Logging into a HTTP Host" {
        BeforeAll {
            $TestValues = @{
                Hostname   = "New-Guid"
                Credential = [pscredential]::new(
                    "$(New-Guid)",
                    ("$(New-Guid)" | ConvertTo-SecureString -AsPlainText -Force)
                )
                UseSSL     = $false
            }
            $Result = Connect-CCMServer @TestValues
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }

        It "Called /Account/Login using the provided Credentials" {
            Should -Invoke Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "POST" -and
                $Uri -eq "http://$($TestValues.Hostname)/Account/Login" -and
                $ContentType -eq "application/x-www-form-urlencoded" -and
                $Body.usernameOrEmailAddress -eq $TestValues.Credential.UserName -and
                $Body.password -eq $TestValues.Credential.GetNetworkCredential().Password
            }
        }

        It "Sets the Protocol Variable" {
            InModuleScope ChocoCCM { $script:Protocol } | Should -Be "http"
        }

        It "Sets the Session Variable" -Skip {
            # TODO: Fix this test.
            InModuleScope ChocoCCM { $script:Session } | Should -Not -BeNullOrEmpty
        }

        It "Sets the Hostname Variable" {
            InModuleScope ChocoCCM { $script:Hostname } | Should -Be $TestValues.Hostname
        }
    }

    Context "Logging into a HTTPS Host" {
        BeforeAll {
            $TestValues = @{
                Hostname   = "New-Guid"
                Credential = [pscredential]::new(
                    "$(New-Guid)",
                    ("$(New-Guid)" | ConvertTo-SecureString -AsPlainText -Force)
                )
                UseSSL     = $true
            }
            $Result = Connect-CCMServer @TestValues
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }

        It "Called /Account/Login using the provided Credentials" {
            Should -Invoke Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Method -eq "POST" -and
                $Uri -eq "https://$($TestValues.Hostname)/Account/Login" -and
                $ContentType -eq "application/x-www-form-urlencoded" -and
                $Body.usernameOrEmailAddress -eq $TestValues.Credential.UserName -and
                $Body.password -eq $TestValues.Credential.GetNetworkCredential().Password
            }
        }

        It "Sets the Protocol Variable" {
            InModuleScope ChocoCCM { $script:Protocol } | Should -Be "https"
        }

        It "Sets the Session Variable" -Skip {
            # TODO: Fix this test.
            InModuleScope ChocoCCM { $script:Session } | Should -Not -BeNullOrEmpty
        }

        It "Sets the Hostname Variable" {
            InModuleScope ChocoCCM { $script:Hostname } | Should -Be $TestValues.Hostname
        }
    }
}