Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMDeploymentStep" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath.EndsWith("GetDeploymentStepForEdit")
        } {
            @{
                name                    = "Deployment Step $($Body.Id)"
                deploymentStepComputers = @{
                    overwritten = $false
                }
            }
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath.EndsWith("GetAllByDeploymentStepId")
        } {
            @{
                result = @{
                    overwritten = $true
                }
            }
        }
    }

    Context "Getting Deployment Steps by ID, including results" {
        BeforeAll {
            $TestParams = @{
                ID             = "583"
                IncludeResults = $true
            }

            $Result = Get-CCMDeploymentStep @TestParams
        }

        It "Calls the API to get the Deployment Step" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/GetDeploymentStepForEdit" -and
                $Body.Id -eq $TestParams.ID
            }
        }

        It "Returns the deployment step, overwriting the deploymentStepComputers results" {
            $Result | Should -Not -BeNullOrEmpty
            $Result.deploymentStepComputers.overwritten | Should -Be $true
        }
    }

    Context "Getting Deployment Steps by InputObject, not including results" {
        BeforeAll {
            $TestParams = @{
                InputObject    = @{ id = "583" }
                IncludeResults = $false
            }

            $Result = Get-CCMDeploymentStep @TestParams
        }

        It "Calls the API to get the Deployment Step" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/GetDeploymentStepForEdit" -and
                $Body.Id -eq $TestParams.InputObject.Id
            }
        }

        It "Returns the deployment step, overwriting the deploymentStepComputers results" {
            $Result | Should -Not -BeNullOrEmpty
            $Result.deploymentStepComputers.overwritten | Should -Be $false
        }
    }

    Context "Getting Deployment Steps by pipelined input" {
        BeforeAll {
            $TestParams = [PSCustomObject]@{
                ID = "583"
            }

            $Result = $TestParams | Get-CCMDeploymentStep
        }

        It "Calls the API to get the Deployment Step" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/GetDeploymentStepForEdit" -and
                $Body.Id -eq $TestParams.ID
            }
        }

        It "Returns the deployment step, overwriting the deploymentStepComputers results" {
            $Result | Should -Not -BeNullOrEmpty
            $Result.deploymentStepComputers.overwritten | Should -Be $false
        }
    }
}