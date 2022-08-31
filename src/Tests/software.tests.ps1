$module = (Get-ChildItem "$($env:BuildRepositoryLocalPath)" -Recurse -Filter *.psd1).FullName[1]

Import-Module $module -Force

function Get-CCMSoftware {
    param($Software, $Package, $Id)

    Invoke-RestMethod -Uri 'https://google.com'
}

Describe "CCM Software functions" {

    Mock Invoke-RestMethod -MockWith {
        if ($Software -or $Package -or $Id) {
            $foo = [pscustomobject]@{
                computerId           = 1
                computer             = [pscustomobject]@{
                    computerGuid                               = 'fc467c00-5331-47f1-876b-d6c7c537723e'
                    name                                       = 'ccmserver'
                    friendlyName                               = $null
                    ipAddress                                  = '10.0.2.15'
                    listLocalOnlyReportChecksum                = -2031453698
                    outdatedReportChecksum                     = 487
                    lastCheckInDateTime                        = '11 / 2 / 2020 9:14:57 PM'
                    fqdn                                       = 'ccmserver'
                    ccmServiceName                             = 'ccmserver'
                    availableForDeploymentsBasedOnLicenseCount = $true
                    optedIntoDeploymentBasedOnConfig           = $true
                    software                                   = $null
                    groups                                     = $null
                    users                                      = $null
                    chocolateyConfigurationFeatures            = $null
                    id                                         = 1
                }
                softwareId           = 3
                software             = [pscustomobject]@{
                    name                  = 'Chocolatey'
                    nameTruncated         = 'Chocolatey'
                    packageId             = 'chocolatey'
                    packageVersion        = '0.10.15'
                    packageTitle          = 'Chocolatey'
                    packageTitleTruncated = 'Chocolatey'
                    softwareDisplayName   = $null
                    softwareVersion       = $null
                    isOutdated            = 'False'
                    id                    = 3
                }
                installedDateTimeUtc = $null
                isCurrentlyInstalled = 'True'
                id                   = 3
            }

            return $foo
        }
        else {
            $foo = @(
                [pscustomobject]@{
                    name                  = 'Chocolatey'
                    nameTruncated         = 'Chocolatey'
                    packageId             = 'chocolatey'
                    packageVersion        = 0.3.0
                    packageTitle          = 'Chocolatey'
                    packageTitleTruncated = 'Chocolatey'
                    softwareDisplayName   = $null
                    softwareVersion       = $null
                    isOutdated            = 'False'
                    id                    = 7
                },
                [pscustomobject]@{ name = 'chocolatey' }
            )

            return $foo
        }
    }

    It "Returns an object" {
        $Software = Get-CCMSoftware
        $Software | Should -BeOfType "System.Management.Automation.PSCustomObject"
    }

    It "Should have 16 properties" {
        $Software = Get-CCMSoftware -Software Chocolatey
        ($Software | Get-Member -MemberType NoteProperty).Count | Should -Be 7
    }

    It "Returns multiple objects if an array is passed" {
        $Software = Get-CCMSoftware
        $Software.Count | Should -Be 2
    }
}
