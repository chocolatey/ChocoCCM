Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Add-CCMGroupMember" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Get-CCMComputer -ModuleName ChocoCCM {
            1..10 | ForEach-Object {
                @{
                    name       = "Computer $_"
                    id         = $_
                    computerId = $_
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
        Mock Get-CCMGroupMember -ModuleName ChocoCCM {
            [pscustomobject]@{
                Id          = "$(New-Guid)"
                Name        = $Group
                Description = "Definitely a real group"
                Groups      = $script:ExistingMemberGroups
                Computers   = $script:ExistingMemberComputers
                CanDeploy   = $true
            }
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
            $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit"
        } {
            if ($Body -is [string]) {
                $Body = $Body | ConvertFrom-Json
            }

            $Body.Computers.ForEach{
                if ($script:ExistingMemberComputers.computerId -notcontains $_.computerId) {
                    $script:ExistingMemberComputers += @{ computerId = $_.computerId ; computerName = "Computer $($_.computerId)" }
                }
            }
            $Body.Groups.ForEach{
                if ($script:ExistingMemberGroups.subGroupId -notcontains $_.subGroupId) {
                    $script:ExistingMemberGroups += @{ subGroupId = $_.subGroupId ; subGroupName = "Group $($_.subGroupId)" }
                }
            }
        }
    }

    Context "Adding a computer to an existing group" {
        BeforeAll {
            $script:ExistingMemberGroups = @()
            $script:ExistingMemberComputers = @()  # No existing members

            $TestParams = @{
                Name     = "$(New-Guid)"
                Computer = @("Computer $(Get-Random -Minimum 1 -Maximum 10)")
            }

            $Result = Add-CCMGroupMember @TestParams
        }

        It "Calls the API to add group members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1] -and
                $Body.Groups.Count -eq 0
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding multiple computers to an existing group" {
        BeforeAll {
            $script:ExistingMemberGroups = @()
            $script:ExistingMemberComputers = @()  # No existing members

            $TestParams = @{
                Name     = "$(New-Guid)"
                Computer = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Computer $_" }
            }

            $Result = Add-CCMGroupMember @TestParams
        }

        It "Calls the API to add group members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1] -and
                $Body.Groups.Count -eq 0
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding a group to an existing group" {
        BeforeAll {
            $script:ExistingMemberGroups = @()  # No existing members
            $script:ExistingMemberComputers = @()

            $TestParams = @{
                Name  = "$(New-Guid)"
                Group = "Group $(Get-Random -Minimum 1 -Maximum 10)"
            }

            $Result = Add-CCMGroupMember @TestParams
        }

        It "Calls the API to add group members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.Count -eq 0
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Groups | Should -Be $TestParams.Group
        }
    }

    Context "Adding multiple groups to an existing group" {
        BeforeAll {
            $script:ExistingMemberGroups = @()  # No existing members
            $script:ExistingMemberComputers = @()

            $TestParams = @{
                Name  = "$(New-Guid)"
                Group = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Group $_" }
            }

            $Result = Add-CCMGroupMember @TestParams
        }

        It "Calls the API to add group members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.Count -eq 0
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Groups | Should -Be $TestParams.Group
        }
    }

    Context "Adding multiple computers and groups to an existing group" {
        BeforeAll {
            $script:ExistingMemberGroups = @()  # No existing members
            $script:ExistingMemberComputers = @()  # No existing members

            $TestParams = @{
                Name     = "$(New-Guid)"
                Computer = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Computer $_" }
                Group    = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { "Group $_" }
            }

            $Result = Add-CCMGroupMember @TestParams
        }

        It "Calls the API to add group members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Groups.subGroupId -eq $TestParams.Group.Split(' ')[-1] -and
                $Body.Computers.computerId -eq $TestParams.Computer.Split(' ')[-1]
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Groups | Should -Be $TestParams.Group
            $Result.Computers | Should -Be $TestParams.Computer
        }
    }

    Context "Adding members that are already present in the group" {
        BeforeAll {
            $script:ExistingMemberGroups = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { @{ subGroupId = $_ ; subGroupName = "Group $($_)" } }
            $script:ExistingMemberComputers = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { @{ computerId = $_ ; computerName = "Computer $($_)" } }

            $TestParams = @{
                Name     = "$(New-Guid)"
                Computer = $script:ExistingMemberComputers.computerName
                Group    = $script:ExistingMemberGroups.subGroupName
            }

            $Result = Add-CCMGroupMember @TestParams
        }

        It "Calls the API to add group members" {
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }
                Write-Host $Body.Groups
                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Groups.Count -eq 0 -and
                ($Body.Computers.computerId | Sort-Object) -eq ($TestParams.Computer.Split(' ')[-1] | Sort-Object)
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Groups | Should -Be $script:ExistingMemberGroups.subGroupName
            $Result.Computers | Should -Be $script:ExistingMemberComputers.computerName
        }
    }

    Context "Adding a non-existent computer to a group" {
        BeforeAll {
            $script:ExistingMemberGroups = @()
            $script:ExistingMemberComputers = @(1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { @{ computerId = $_ ; computerName = "Computer $($_)" } })

            $TestParams = @{
                Name     = "$(New-Guid)"
                Computer = @("Saturn")
            }

            $Result = Add-CCMGroupMember @TestParams -WarningVariable "StoredWarning"
        }

        It "Warns that the computer doesn't exist and it's not being added" {
            # Not a great test, but it will mean that if someone is relying on this message and we change it, we'll have to consider it.
            $StoredWarning | Should -Be "A computer with the name $($TestParams.Computer) could not be found, skipping adding it to the group"
        }

        It "Calls the API to add group members without including the non-existent computer" {
            # It's possible that if nothing changes, this shouldn't be called - but that's somewhat confused by us passing existing computers and not existing groups.
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Computers.Count -eq $script:ExistingMemberComputers.Count -and # This should not have increased.
                $Body.Groups.Count -eq 0
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Computers | Should -Be $script:ExistingMemberComputers.computerName
        }
    }

    Context "Adding a non-existent group to a group" {
        BeforeAll {
            $script:ExistingMemberGroups = 1..10 | Get-Random -Count (Get-Random -Minimum 1 -Maximum 10) | ForEach-Object { @{ subGroupId = $_ ; subGroupName = "Group $($_)" } }
            $script:ExistingMemberComputers = @()

            $TestParams = @{
                Name  = "$(New-Guid)"
                Group = @("Solar System")
            }

            $Result = Add-CCMGroupMember @TestParams -WarningVariable "StoredWarning"
        }

        It "Warns that the computer doesn't exist and it's not being added" {
            # Not a great test, but it will mean that if someone is relying on this message and we change it, we'll have to consider it.
            $StoredWarning | Should -Be "A group with the name $($TestParams.Group) could not be found, skipping adding it to the group"
        }

        It "Calls the API to add group members without including the non-existent group" {
            # It's possible that if nothing changes, this shouldn't be called - but that's somewhat confused by us passing existing computers and not existing groups.
            Should -Invoke Invoke-RestMethod -ModuleName ChocoCCM -Scope Context -Times 1 -Exactly -ParameterFilter {
                Write-Host $Body
                if ($Body -is [string]) {
                    $Body = $Body | ConvertFrom-Json
                }

                $Method -eq "POST" -and
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit" -and
                $ContentType -eq "application/json" -and
                $Body.Groups.Count -eq 0 -and # Groups do not get passed back, even if they already are there. See the comment above!
                $Body.Computers.Count -eq 0

                Write-Host "$($Body.Groups.Count)" "$($script:ExistingMemberGroups.Count)"
            }
        }

        It "Returns the updated group" {
            $Result | Should -BeOfType [PSCustomObject]

            $Result.Name | Should -Be $TestParams.Name
            $Result.Computers | Should -Be $script:ExistingMemberComputers.computerName
        }
    }

    Context "Adding members to a group that doesn't exist" {
        BeforeAll {
            Mock Get-CCMGroupMember -ModuleName ChocoCCM {
                throw [Microsoft.PowerShell.Commands.HttpResponseException]::new("Response status code does not indicate success: 400 (Bad Request).")
            }

            $TestParams = @{
                Name     = "$(New-Guid)"
                Computer = "Some Computer"
            }
        }

        # This may be a terrible test.
        It "Throws an error when the group doesn't exist." {
            { Add-CCMGroupMember @TestParams } | Should -Throw
        }
    }

    # Skipping: This needs thought, as it currently just responds with handy content for the PWD
    Context "Completing Parameter Arguments" -Skip {
        BeforeAll {
            Mock Get-CCMGroup -ModuleName ChocoCCM {
                "Alpha", "Bravo", "Charlie", "Delta" | ForEach-Object {
                    @{ Name = $_ }
                }
            }
        }

        It "Has an argument completer for Name that lists all group names by default" {
            $Command = "Add-CCMGroupMember -Name ''"
            $Completions = [System.Management.Automation.CommandCompletion]::CompleteInput($Command, $Command.Length, $null)

            $Completions.CompletionMatches.CompletionText | Should -HaveCount 4
        }

        It "Has an argument completer for Name that filters group names by entered text" {
            $Command = "Add-CCMGroupMember -Name 'Alph'"
            $Completions = [System.Management.Automation.CommandCompletion]::CompleteInput($Command, $Command.Length, $null)

            $Completions.CompletionMatches.CompletionText | Should -HaveCount 1
            $Completions.CompletionMatches.CompletionText | Should -Be "Alpha"
        }
    }

    Context "Failing to add a group member" {
        BeforeAll {
            Mock Invoke-RestMethod -ModuleName ChocoCCM -ParameterFilter {
                $Uri.AbsolutePath -eq "/api/services/app/Groups/CreateOrEdit"
            } {
                throw [Microsoft.PowerShell.Commands.HttpResponseException]::new("Response status code does not indicate success: 400 (Bad Request).")
            }

            $TestParams = @{
                Name  = "$(New-Guid)"
                Group = "Group $(Get-Random -Minimum 1 -Maximum 10)"
            }
        }

        It "Throws an error when the group doesn't exist." {
            { Add-CCMGroupMember @TestParams } | Should -Throw
        }
    }
}