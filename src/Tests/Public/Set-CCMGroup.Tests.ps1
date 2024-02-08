Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Set-CCMGroup" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMGroupMember -ModuleName ChocoCCM {
            @{
                Id          = 1
                Name        = $Group
                Description = "An existing description"
                Computers   = @()
                Groups      = @()
            }
        }
    }

    Context "Updating a description" {
        BeforeAll {
            $TestParams = @{
                Group          = "Finance"
                NewDescription = "Computers in the finance division"
            }

            $Result = Set-CCMGroup @TestParams
        }

        It "Gets the existing group information" {
            Should -Invoke Get-CCMGroupMember -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Group -eq $TestParams.Group
            }
        }

        It "Calls the API to update the group" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and

                $Body.Id -eq 1 -and
                $Body.Name -eq $TestParams.Group -and
                $Body.Description -eq $TestParams.NewDescription
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Updating a name" {
        BeforeAll {
            $TestParams = @{
                Group   = "IT"
                NewName = "TheBestComputers"
            }

            $Result = Set-CCMGroup @TestParams
        }

        It "Gets the existing group information" {
            Should -Invoke Get-CCMGroupMember -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Group -eq $TestParams.Group
            }
        }

        It "Calls the API to update the group" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and

                $Body.Id -eq 1 -and
                $Body.Name -eq $TestParams.NewName -and
                $Body.Description -eq "An existing description"  # Has not been changed
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Updating a name and description" {
        # Set-CCMGroup -Group Test -NewName NewMachineImaged -Description 'Group for freshly imaged machines needing a baseline package pushed to them'
        BeforeAll {
            $TestParams = @{
                Group          = "Test"
                NewName        = "NewMachineImaged"
                NewDescription = "Group for freshly imaged machines needing a baseline package pushed to them"
            }

            $Result = Set-CCMGroup @TestParams
        }

        It "Gets the existing group information" {
            Should -Invoke Get-CCMGroupMember -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                $Group -eq $TestParams.Group
            }
        }

        It "Calls the API to update the group" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and

                $Body.Id -eq 1 -and
                $Body.Name -eq $TestParams.NewName -and
                $Body.Description -eq $TestParams.NewDescription
            }
        }

        It "Returns Nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }
}