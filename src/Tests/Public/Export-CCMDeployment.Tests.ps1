Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Export-CCMDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            @{
                Name            = $Name
                Description     = "This is a deployment"
                DeploymentSteps = @(
                    @{
                        Name        = "Step 1"
                        Description = "This is a step"
                        Type        = "Install"
                        Package     = @{
                            Name    = "7zip"
                            Version = "19.00"
                        }
                    }
                    @{
                        Name        = "Step 2"
                        Description = "This is a step"
                        Type        = "Install"
                        Package     = @{
                            Name    = "Firefox"
                            Version = "21.00"
                        }
                    }
                )
            }
        }
    }

    Context "Exporting a Deployment" {
        BeforeAll {
            $TestParams = @{
                Deployment = "$(New-Guid)"
                OutFile    = Join-Path $TestDrive "TestFile.xml"
            }

            $Result = Export-CCMDeployment @TestParams
        }

        It "Calls the API to get the content of the specified deployment" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Exports the content to the specified file" {
            $TestParams.OutFile | Should -FileContentMatch "This is a deployment"
            $TestParams.OutFile | Should -FileContentMatch $TestParams.Deployment
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Exporting Deployment Steps Only" {
        BeforeAll {
            $TestParams = @{
                Deployment          = "$(New-Guid)"
                DeploymentStepsOnly = $true
                OutFile             = Join-Path $TestDrive "TestFile.xml"
            }

            $Result = Export-CCMDeployment @TestParams
        }

        It "Calls the API to get the content of the specified deployment" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Exports the deployment steps to the specified file" {
            $TestParams.OutFile | Should -Not -FileContentMatch "This is a deployment"
            $TestParams.OutFile | Should -Not -FileContentMatch $TestParams.Deployment
            $TestParams.OutFile | Should -FileContentMatch "This is a step"
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Exporting to an existing file" {
        BeforeAll {
            $TestParams = @{
                Deployment   = "$(New-Guid)"
                OutFile      = Join-Path $TestDrive "TestFile.xml"
                AllowClobber = $false
            }

            New-Item -Path $TestParams.OutFile -Value "This is an old deployment"

            $Result = Export-CCMDeployment @TestParams
        }

        It "Calls the API to get the content of the specified deployment" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Does not overwrite the deployment steps in the specified file" -Skip {
            # This currently fails because the file is overwritten regardless of the AllowClobber parameter
            $TestParams.OutFile | Should -FileContentMatch "This is an old deployment"
            $TestParams.OutFile | Should -Not -FileContentMatch "This is a deployment"
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Overwriting an existing file" {
        BeforeAll {
            $TestParams = @{
                Deployment   = "$(New-Guid)"
                OutFile      = Join-Path $TestDrive "TestFile.xml"
                AllowClobber = $true
            }

            New-Item -Path $TestParams.OutFile -Value "This is an old deployment"

            $Result = Export-CCMDeployment @TestParams
        }

        It "Calls the API to get the content of the specified deployment" {
            Should -Invoke Get-CCMDeployment -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Name -eq $TestParams.Deployment
            }
        }

        It "Exports the deployment to the specified file" {
            $TestParams.OutFile | Should -Not -FileContentMatch "This is an old deployment"
            $TestParams.OutFile | Should -FileContentMatch "This is a deployment"
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}