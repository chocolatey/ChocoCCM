Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "New-CCMDeploymentStep" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            @{Id = "ID:$Name" }
        }
        Mock Get-CCMGroup -ModuleName ChocoCCM {
            foreach ($Group in $Group) {
                @{
                    Name = $Group
                    Id   = "ID:$Group"
                }
            }
        }
    }

    Context "Creating a basic deployment step" {
        BeforeAll {
            $TestParams = @{
                Deployment   = "PowerShell"
                Name         = "From ChocoCCM"
                TargetGroup  = "WebServers"
                Type         = "Basic"
                ChocoCommand = "upgrade"
                PackageName  = "firefox"
            }

            $Result = New-CCMDeploymentStep @TestParams
        }

        It "Calls the API to create the basic deployment step" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/CreateOrEdit" -and
                $ContentType -eq "application/json" -and

                $Body.Name -eq $TestParams.Name -and
                $Body.DeploymentPlanId -eq "ID:$($TestParams.Deployment)" -and
                $Body.DeploymentStepGroups.groupname -eq $TestParams.TargetGroup -and
                $Body.script -eq "$($TestParams.ChocoCommand.ToLower())|$($TestParams.PackageName)"
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Creating an advanced deployment step" {
        BeforeAll {
            $TestParams = @{
                Deployment  = "PowerShell"
                Name        = "From ChocoCCM"
                TargetGroup = "All", "PowerShell"
                Type        = "Advanced"
                Script      = {
                    foreach ($p in Get-Process) {
                        Write-Host $p.PID
                    }
                    Write-Host "end"
                }
            }

            $Result = New-CCMDeploymentStep @TestParams
        }

        It "Calls the API to create the basic deployment step" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/CreateOrEditPrivileged" -and
                $ContentType -eq "application/json" -and

                $Body.Name -eq $TestParams.Name -and
                $Body.DeploymentPlanId -eq "ID:$($TestParams.Deployment)" -and
                "$($Body.DeploymentStepGroups.groupname)" -eq "$($TestParams.TargetGroup)" -and
                $Body.script -eq $TestParams.Script.ToString()
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Creating an advanced deployment step from a file" {
        # New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script {(Get-Content C:\script.txt)}
        BeforeAll {
            New-Item $TestDrive\script.txt -ItemType File -Value 'foreach ($p in Get-Process) { Write-Host $p.PID } Write-Host "end"'
            $TestParams = @{
                Deployment  = "PowerShell"
                Name        = "From ChocoCCM"
                TargetGroup = "All", "PowerShell"
                Type        = "Advanced"
                Script      = { (Get-Content $TestDrive\script.txt) }
            }

            $Result = New-CCMDeploymentStep @TestParams
        }

        It "Calls the API to create the basic deployment step" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentSteps/CreateOrEditPrivileged" -and
                $ContentType -eq "application/json" -and

                $Body.Name -eq $TestParams.Name -and
                $Body.DeploymentPlanId -eq "ID:$($TestParams.Deployment)" -and
                "$($Body.DeploymentStepGroups.groupname)" -eq "$($TestParams.TargetGroup)" -and
                $Body.script -eq $TestParams.Script.ToString()
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}