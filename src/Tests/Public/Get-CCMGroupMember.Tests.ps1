[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPlaceCloseBrace', '', Justification = 'This cannot obey both PSPlaceCloseBrace and the hashtable spacing rules.')]
param()

Import-Module $PSScriptRoot\..\..\ChocoCCM.psd1

Describe "Get-CCMGroupMember" {
    BeforeAll {
        InModuleScope -ModuleName ChocoCCM {
            $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            $script:HostName = "localhost"
            $script:Protocol = "http"
        }
        Mock Invoke-RestMethod -ModuleName ChocoCCM
        Mock Get-CCMGroup -ModuleName ChocoCCM {
            @{
                Id                       = if ($Id) {
                    $Id
                } else {
                    $Group.Split(' ')[-1]
                }
                Name                     = if ($Group) {
                    $Group
                } else {
                    "Group $Id"
                }
                Description              = "A real group."
                Groups                   = @("Groups")
                Computers                = @("Computers")
                isEligibleForDeployments = "ValueOfIsEligibleForDeployments"
            }
        }
    }

    Context "Getting group membership" {
        BeforeAll {
            $TestParams = @{
                Group = "Group 1"
            }

            $Result = Get-CCMGroupMember @TestParams
        }

        It "Calls Get-CCMGroup to get the group ID" {
            Should -Invoke Get-CCMGroup -Module ChocoCCM -Scope Context -ParameterFilter {
                $Group -eq $TestParams.Group
            }
        }

        It "Calls Get-CCMGroup to get the group details based on the returned ID" {
            Should -Invoke Get-CCMGroup -Module ChocoCCM -Scope Context -ParameterFilter {
                $Id -eq $TestParams.Group.Split(' ')[-1]
            }
        }

        It "Returns a new object containing information on the group membership" {
            # This test is rubbish, but we want to show that if we break "the contract" (e.g. the keys returned not matching the API returns)
            # then we need to be mindful that we are changing the output a customer _may_ expect, and have to adjust tests accordingly.
            $Result.Id | Should -Be "1"
            $Result.Name | Should -Be "Group 1"
            $Result.Description | Should -Be "A real group."
            $Result.Groups | Should -Be @( "Groups" )
            $Result.Computers | Should -Be @( "Computers" )
            $Result.CanDeploy | Should -Be "ValueOfIsEligibleForDeployments"
        }
    }
}