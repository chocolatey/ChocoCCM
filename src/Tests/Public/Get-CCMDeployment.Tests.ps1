Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMDeployment" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetAll"
        } -MockWith {
            $result = @{
                result = @()
            }
            $result.result += [PSCustomObject]@{
                name           = "bob"
                id             = 0
                deploymentPlan = @{
                    name = "planbob"
                }
            }
            $result.result += 1..9 | ForEach-Object {
                [PSCustomObject]@{
                    name           = "Deployment $_"
                    id             = $_
                    deploymentPlan = @{
                        name = "plan$_"
                    }
                }
            }
            $result
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit"
        } -MockWith {
            @{
                result = @{
                    name           = "Deployment $($Uri.Query.Split("=")[-1])"
                    id             = $Uri.Query.Split("=")[-1]
                    deploymentPlan = @{
                        name = "plan$($Uri.Query.Split("=")[-1])"
                    }
                }
            }
        }
        Mock Get-CCMDeploymentStep -ModuleName ChocoCCM -MockWith {
            @{ content = $true }
        }
    }

    Context "Getting all deployments" {
        BeforeAll {
            $Result = Get-CCMDeployment
        }

        It "Calls the API to get all deployments" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetAll"
            }
        }

        It "Returns all deployments, including deploymentPlans" {
            $Result | Should -HaveCount 10
            $Result.deploymentPlan.deploymentSteps | Should -BeNullOrEmpty
            $Result.deploymentPlan | Should -Not -BeNullOrEmpty
        }
    }

    Context "Getting a deployment by name" {
        BeforeAll {
            $TestParams = @{
                Name = "bob"
            }

            $Result = Get-CCMDeployment @TestParams
        }

        It "Calls the API to get all deployments" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetAll"
            }
        }

        It "Calls the API to get the specific deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit" -and
                $Uri.Query -eq "?Id=0"
            }
        }

        It "Returns the correct deployment plan" {
            $Result.name | Should -Be "plan0"
            $Result.deploymentSteps | Should -BeNullOrEmpty
            $Result | Should -HaveCount 1
        }
    }

    Context "Getting a deployment by ID" {
        BeforeAll {
            $TestParams = @{
                Id = Get-Random -Minimum 1 -Maximum 9
            }

            $Result = Get-CCMDeployment @TestParams
        }

        It "Does not call the API to get all deployments" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetAll"
            }
        }

        It "Calls the API to get the specific deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit" -and
                $Uri.Query -eq "?Id=$($TestParams.Id)"
            }
        }

        It "Returns the correct deployment plan" {
            $Result.name | Should -Be "plan$($TestParams.Id)"
            $Result.deploymentSteps | Should -BeNullOrEmpty
            $Result | Should -HaveCount 1
        }
    }

    Context "Including Step Results with ID" {
        BeforeAll {
            $TestParams = @{
                Id                 = Get-Random -Minimum 1 -Maximum 9
                IncludeStepResults = $true
            }

            $Result = Get-CCMDeployment @TestParams
        }

        It "Does not call the API to get all deployments" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 0 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetAll"
            }
        }

        It "Calls the API to get the specific deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit" -and
                $Uri.Query -eq "?Id=$($TestParams.Id)"
            }
        }

        It "Returns the correct deployment plan" {
            $Result.name | Should -Be "plan$($TestParams.Id)"
            $Result.deploymentSteps | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
        }
    }

    Context "Including Step Results with Name" {
        BeforeAll {
            $TestParams = @{
                Name               = "bob"
                IncludeStepResults = $true
            }

            $Result = Get-CCMDeployment @TestParams
        }

        It "Calls the API to get all deployments" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetAll"
            }
        }

        It "Calls the API to get the specific deployment" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit" -and
                $Uri.Query -eq "?Id=0"
            }
        }

        It "Returns the correct deployment plan, including deployment steps" {
            $Result.name | Should -Be "plan0"
            $Result | Should -HaveCount 1
            $Result.deploymentSteps | Should -Not -BeNullOrEmpty
        }
    }
}