Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Set-CCMDeploymentStep" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM
    }

    # Skipping: This function is currently not fully implemented
    Context "Setting a basic deployment step" -Skip {
        BeforeAll {
            $TestParams = @{
                Deployment              = "Google Chrome Update"
                Step                    = "Upgrade"
                TargetGroup             = "LabPCs"
                ExecutionTimeoutSeconds = 14400
                ChocoCommand            = "Upgrade"
                PackageName             = "googlechrome"
            }

            $Result = Set-CCMDeploymentStep @TestParams
        }

        It "Calls Get-CCMDeployment to get the deployment ID" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Calls Get-CCMDeployment to get the existing configuration" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Id -eq "$($TestParams.Deployment)ID"
            }
        }

        It "Calls the API to update the deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Role/GetRoles" -and
                $Uri.Query -eq "?permission=" -and
                $ContentType -eq "application/json" -and
                $Body.usernameOrEmailAddress -eq $TestParams.Credential.UserName -and
                $Body.password -eq $TestParams.Credential.GetNetworkCredential().Password
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    # Skipping: This function is currently not fully implemented
    Context "Setting a complex deployment step" -Skip {
        BeforeAll {
            $TestParams = @{
                Deployment  = "OS Version"
                Step        = "Gather Info"
                TargetGroup = "US-East servers"
                Script      = {
                    $data = Get-WMIObject win32_OperatingSystem
                    [pscustomobject]@{
                        Name    = $data.caption
                        Version = $data.version
                    }
                }
            }

            $Result = Set-CCMDeploymentStep @TestParams
        }

        It "Calls Get-CCMDeployment to get the deployment ID" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Calls Get-CCMDeployment to get the existing configuration" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Id -eq "$($TestParams.Deployment)ID"
            }
        }

        It "Calls the API to update the deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "GET" -and
                $Uri.AbsolutePath -eq "/api/services/app/Role/GetRoles" -and
                $Uri.Query -eq "?permission=" -and
                $ContentType -eq "application/json" -and
                $Body.usernameOrEmailAddress -eq $TestParams.Credential.UserName -and
                $Body.password -eq $TestParams.Credential.GetNetworkCredential().Password
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}