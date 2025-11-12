Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Add-CCMGroup" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMComputer -ModuleName ChocoCCM {
            1..10 | ForEach-Object {
                @{
                    name = "Computer $_"
                    id   = $_
                }
            }
        }
        Mock Get-CCMGroup -ModuleName ChocoCCM {
            1..10 | ForEach-Object {
                @{
                    name = "Group $_"
                    id   = $_
                }
            }
        }
    }

    Context "Adding a new group with no members" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                # Group     = @()
                # Computer  = @()
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with no members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.Count -eq 0 -and
                $Body.Computers.Count -eq 0
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a new group containing a computer" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                # Group     = @()
                Computer    = "Computer $(Get-Random -Minimum 1 -Maximum 10)"
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.Count -eq 0 -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1]
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    # Containing multiple computers
    Context "Adding a new group containing multiple computers" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                # Group     = @()
                Computer    = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Computer $_" }
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computers" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.Count -eq 0 -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1]

                $script:ResultComputers = $Body.Computers
            }

            $script:ResultComputers | Should -HaveCount $TestParams.Computer.Count
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a new group containing another group" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                Group       = "Group $(Get-Random -Minimum 1 -Maximum 10)"
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.Count -eq 0
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a new group containing multiple groups" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                Group       = 1..10 | Get-Random -Count (Get-Random -Minimum 2 -Maximum 10) | ForEach-Object { "Group $_" }
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.Count -eq 0
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a new group containing a group and a computer" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                Group       = "Group $(Get-Random -Minimum 1 -Maximum 10)"
                Computer    = "Computer $(Get-Random -Minimum 1 -Maximum 10)"
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1]
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a new group containing a group and multiple computers" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                Group       = "Group $(Get-Random -Minimum 1 -Maximum 10)"
                Computer    = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Computer $_" }
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1]
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a new group containing multiple groups and a computer" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                Group       = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Group $_" }
                Computer    = "Computer $(Get-Random -Minimum 1 -Maximum 10)"
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1]
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a new group containing multiple groups and multiple computers" {
        BeforeAll {
            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
                Group       = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Group $_" }
                Computer    = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Computer $_" }
            }

            $Result = Add-CCMGroup @TestParams
        }

        It "Calls the API to create the new group with the computer" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1]
            }
        }

        It "Returns the new group" {
            $Result | Should -BeOfType [PSCustomObject]
            $Result.name | Should -Be $TestParams.Name
            $Result.description | Should -Be $TestParams.Description
            $Result.groups | Should -Be $TestParams.Group
            $Result.computers | Should -Be $TestParams.Computer
        }
    }

    # Creating an already existing group name
    Context "Adding a new group with an already existing name" -Skip {
        # This is apparently fine to do. Hmph.
        # Given the way it's written (e.g. using $Current to update the object?),
        # I can't tell if this is good or bad. It seems to be modelled on Add-CCMGroupMember... sort of.
    }

    Context "Failing to create a group" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM {
                throw "A server error occurred"
            }

            $TestParams = @{
                Name        = "$(New-Guid)"
                Description = "$(New-Guid)"
            }
        }

        It "Surfaces the error" {
            { $Result = Add-CCMGroup @TestParams } | Should -Throw
        }

        It "Calls the API to create the new group with no members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Name -eq $TestParams.Name -and
                $Body.Description -eq $TestParams.Description -and
                $Body.Groups.Count -eq 0 -and
                $Body.Computers.Count -eq 0
            }
        }

        It "Returns nothing." {
            $Result | Should -BeNullOrEmpty
        }
    }

    # Creating a group containing non-existent computers
    # Similarly, this won't complain. Maybe it should?

    # Creating a group containing non-existent groups
    # Similarly, this won't complain. Maybe it should?
}