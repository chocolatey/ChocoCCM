$module = (Get-ChildItem "$($env:BuildRepositoryLocalPath)" -Recurse -Filter *.psd1).FullName[1]

Import-Module $module -Force

function Get-CCMComputer {
    param($Computer)

    Invoke-RestMethod -Uri 'https://google.com'
}

Describe "CCM Computer Functions" {

    Mock Invoke-RestMethod -MockWith {

        if ($Computer -and $Computer.Count -gt 1) {
            $Computer | ForEach-Object { [pscustomobject] @{ name = $_ } }
        }
        else {
            $foo = [pscustomobject]@{
                computerGuid                               = "$((New-Guid).Guid)"
                name                                       = 'ccmserver'
                friendlyName                               = $null
                ipAddress                                  = 10.0.2.15
                listLocalOnlyReportChecksum                = -2031453698
                outdatedReportChecksum                     = 487
                lastCheckInDateTime                        = "$(Get-Date)"
                fqdn                                       = 'ccmserver'
                ccmServiceName                             = 'ccmserver'
                availableForDeploymentsBasedOnLicenseCount = True
                optedIntoDeploymentBasedOnConfig           = True
                software                                   = {}
                groups                                     = {}
                users                                      = {}
                chocolateyConfigurationFeatures            = {}
                id                                         = 1
            }

            return $foo
        }
    }

    It "Returns an object" {
        $computer = Get-CCMComputer
        $computer | Should -BeOfType "System.Management.Automation.PSCustomObject"
    }

    It "Should have 16 properties" {
        $computer = Get-CCMComputer -Computer Foo
        ($computer | Get-Member -MemberType NoteProperty).Count | Should -Be 16
    }

    It "Returns multiple objects if an array is passed" {
        $computer = Get-CCMComputer -Computer webserver, dbserver
        $computer.Count | Should -Be 2
    }
}
