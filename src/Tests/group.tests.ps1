$module = (Get-ChildItem "$($env:BuildRepositoryLocalPath)" -Recurse -Filter *.psd1).FullName[1]

Import-Module $module -Force

Function Add-CCMGroup {
    
    Invoke-RestMethod -Uri 'https://google.com'
}

Function Add-CCMGroupMember {

    Invoke-RestMethod -Uri 'https://google.com'
}

Function Get-CCMGroup {
    Param($Group, $Id)

    Invoke-RestMethod -Uri 'https://google.com'

}

Function Get-CCMGroupMember {
    Param()

    Invoke-RestMethod -Uri 'https://google.com'

}

Function Remove-CCMGroupMember {
    Param()

    Invoke-RestMethod -Uri 'https://google.com'

}

Function Set-CCMGroup {
    Param()

    Invoke-RestMethod -Uri 'https://google.com'

}

Describe "Get-CCMGroup Tests" {
    Mock Invoke-RestMethod {
        if ($Group -or $Id) {
            $foo = [pscustomobject]@{
                name                                                      = 'Pester'
                description                                               = 'Group For Pester Tests'
                totalcomputercount                                        = 3
                allComputersareavailablefordeploymentsbasedonlicensecount = $true
                allComputerAreOptedIntoDeploymentBasedOnConfig            = $true
                isEligibleForDeployments                                  = $true
                id                                                        = 1
            }

            return $foo

        }
        else {

            $foo = @(
                [pscustomobject]@{
                    name = 'foo'
                },
                [pscustomobject]@{
                    name = 'bar'
                }
            )

            return $foo
        }
    }

    It "Returns a PSCustomObject" {

        $group = Get-CCMGroup
        $group | Should -BeOfType "System.Management.Automation.PSCustomObject"

    }

    It "Should have 7 properties" {

        $group = Get-CCMGroup -Group Pester
        ($Group | Get-member -MemberType NoteProperty).Count | Should -Be 7
    }

    It "Can return multiple objects" {
        $group = Get-CCMGroup
        $group.Count | Should -BeGreaterThan 1
    }

    It "Should have a Name property" {
        $group = Get-CCMGroup -Group Pester
        'Name' | Should -BeIn ($group | Get-Member -MemberType NoteProperty).Name
    }

    It "Should have an 'AllComputersAreAvailableForDeploymentsBasedOnLicenseCount' property" {
        $group = Get-CCMGroup -Group Pester
        'AllComputersAreAvailableForDeploymentsBasedOnLicenseCount' | Should -BeIn ($group | Get-Member -MemberType NoteProperty).Name
    }
    
    It "Should have an 'AllComputersAreOptedIntoDeploymentBasedOnConfig' Property" {
        $group = Get-CCMGroup -Group Pester
        'allComputerAreOptedIntoDeploymentBasedOnConfig' | Should -BeIn ($group | Get-member).name
    }

    It "Should have a 'Description' Property" {
        $group = Get-CCMGroup -Group Pester
        'Description' | Should -BeIn ($Group | Get-Member).Name
    }

    It "Should have an 'Id' Property" {
        $group = Get-CCMGroup -Group Pester
        'Description' | Should -BeIn ($Group | Get-Member).Name
    }

    It "Should have an 'IsEligibleForDeployments' Property" {
        $group = Get-CCMGroup -Group Pester
        'IsEligibleForDeployments' | Should -BeIn ($group | Get-Member).Name
    }

    It "Should have a 'TotalComputerCount' Property" {
        $group = Get-CCMGroup -Group Pester
        'TotalComputerCount' | Should -BeIn ($Group | Get-Member).Name
    }

}

Describe "Add-CCMGroup Tests" {
    Mock Invoke-RestMethod {
       
            $group = [pscustomobject]@{
                name        = 'Foo'
                description = 'Some description'
                groups      = $null
                computers   = @([pscustomobject]@{name ='foo'; id= 1},[pscustomobject]@{name='bob';id=2})
            }
        

        return $group
    }

    It "Returns a PSCustomObject" { 
        $group = Add-CCMGroup -Name 'Foo' -Description 'Funky Pester Test' -Computer @([pscustomobject]@{name = 'foo'; id = 1 }, [pscustomobject]@{name = 'bob'; id = 2 })
        $group | Should -BeOfType "System.Management.Automation.PSCustomObject"
    }

    It "Should have 4 properties" {

        $group = Add-CCMGroup
        ($group | Get-Member -MemberType NoteProperty).Count | Should -BeExactly 4cd ..
    }
}

