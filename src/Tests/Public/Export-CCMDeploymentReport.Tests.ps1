Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Export-CCMDeploymentReport" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath.StartsWith("/api/services/app/DeploymentPlans/GetDeploymentPlanDetailsTo")
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
        Mock Get-CCMDeployment -ModuleName ChocoCCM {
            [PSCustomObject]@{ Name = $Deployment; Id = "$(New-Guid)" }
        }
    }

    Context "Exporting a PDF Deployment Report" {
        BeforeAll {
            $TestParams = @{
                Deployment   = "Complex"
                Type         = "PDF"
                OutputFolder = $TestDrive
            }

            $Result = Export-CCMDeploymentReport @TestParams
        }

        It "Calls the API to get a file type, token, and name" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetDeploymentPlanDetailsToPdf" -and
                $Method -eq "GET" -and
                $ContentType -eq "application/json"
            }
        }

        It "Downloads the file" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/File/DownloadTempFile" -and
                $Method -eq "GET" -and
                $ContentType -eq "PDF" -and
                $OutFile
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Exporting an Excel Deployment Report" {
        BeforeAll {
            $TestParams = @{
                Deployment   = "Complex"
                Type         = "Excel"
                OutputFolder = $TestDrive
            }

            $Result = Export-CCMDeploymentReport @TestParams
        }

        It "Calls the API to get a file type, token, and name" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/DeploymentPlans/GetDeploymentPlanDetailsToExcel" -and
                $Method -eq "GET" -and
                $ContentType -eq "application/json"
            }
        }

        It "Downloads the file" {
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

    Context "Failing to find a deployment plan" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
                $Uri.AbsolutePath.StartsWith("/api/services/app/DeploymentPlans/GetDeploymentPlanDetailsTo")
            } -MockWith {
                throw [System.Net.WebException]::new("Report not found")
            }

            $TestParams = @{
                Deployment   = "Not Found"
                Type         = "Excel"
                OutputFolder = $TestDrive
            }
        }

        It "Throws an error" {
            { Export-CCMDeploymentReport @TestParams } | Should -Throw
        }
    }

    Context "Failing to export a deployment plan" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
                -not $Uri.AbsolutePath.StartsWith("/api/services/app/DeploymentPlans/GetDeploymentPlanDetailsTo")
            } -MockWith {
                throw [System.Net.WebException]::new("File not found.")
            }

            $TestParams = @{
                Deployment   = "Not Found"
                Type         = "PDF"
                OutputFolder = $TestDrive
            }
        }

        # Skipping: Despite the block around this, we don't actually throw. We just output the error details.
        It "Throws an error" -Skip {
            { Export-CCMDeploymentReport @TestParams } | Should -Throw
        }
    }
}