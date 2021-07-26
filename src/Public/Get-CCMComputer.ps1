Function Get-CCMComputer {
    <#
    .SYNOPSIS
    Returns information about computers in CCM
    
    .DESCRIPTION
    Query for all, or by computer name/id to retrieve information about the system as reported in Central Management
    
    .PARAMETER Computer
    Returns the specified computer(s)
    
    .PARAMETER Id
    Returns the information for the computer with the specified id
    
    .EXAMPLE
    Get-CCMComputer

    .EXAMPLE
    Get-CCMComputer -Computer web1

    .EXAMPLE
    Get-CCMComputer -Id 13
    
    .NOTES
    
    #>
    [cmdletBinding(DefaultParameterSetName = "All", HelpUri = "https://chocolatey.org/docs/get-ccmcomputer")]
    Param(

        [Parameter(Mandatory, ParameterSetName = "Computer")]
        [string[]]
        $Computer,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id

    )

    begin {
        If (-not $Session) {

            throw "Unauthenticated! Please run Connect-CCMServer first"

        }

    }

    process {

        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Computers/GetAll" -WebSession $Session
        } 
        
        Switch ($PSCmdlet.ParameterSetName) {
          

            "Computer" {
                
                Foreach ($c in $computer) {

                    $records.result | Where-Object { $_.name -match "$c" } | Foreach-Object {
                        [PSCustomObject]@{
                            computerGuid                               = $_.computerGuid
                            name                                       = $_.name
                            friendlyName                               = $_.friendlyName
                            ipAddress                                  = $_.ipAddress
                            listLocalOnlyReportChecksum                = $_.listLocalOnlyReportChecksum
                            outdatedReportChecksum                     = $_.outdatedReportChecksum
                            lastCheckInDateTime                        = $_.lastCheckInDateTime
                            fqdn                                       = $_.fqdn
                            ccmServiceName                             = $_.ccmServiceName
                            availableForDeploymentsBasedOnLicenseCount = $_.availableForDeploymentsBasedOnLicenseCount
                            optedIntoDeploymentBasedOnConfig           = $_.optedIntoDeploymentBasedOnConfig
                            software                                   = $_.software
                            groups                                     = $_.groups
                            users                                      = $_.users
                            chocolateyConfigurationFeatures            = $_.chocolateyConfigurationFeatures
                            id                                         = $_.id
                        }
                    }
                }
            }

            "Id" {

                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Computers/GetComputerForEdit?Id=$Id" -WebSession $Session
                $records | Foreach-Object {
                    [PSCustomObject]@{
                        computerGuid                               = $_.computerGuid
                        name                                       = $_.name
                        friendlyName                               = $_.friendlyName
                        ipAddress                                  = $_.ipAddress
                        listLocalOnlyReportChecksum                = $_.listLocalOnlyReportChecksum
                        outdatedReportChecksum                     = $_.outdatedReportChecksum
                        lastCheckInDateTime                        = $_.lastCheckInDateTime
                        fqdn                                       = $_.fqdn
                        ccmServiceName                             = $_.ccmServiceName
                        availableForDeploymentsBasedOnLicenseCount = $_.availableForDeploymentsBasedOnLicenseCount
                        optedIntoDeploymentBasedOnConfig           = $_.optedIntoDeploymentBasedOnConfig
                        software                                   = $_.software
                        groups                                     = $_.groups
                        users                                      = $_.users
                        chocolateyConfigurationFeatures            = $_.chocolateyConfigurationFeatures
                        id                                         = $_.id
                    }
                }
            }

            default {
                $records.result | Foreach-Object {
                    [PSCustomObject]@{
                        computerGuid                               = $_.computerGuid
                        name                                       = $_.name
                        friendlyName                               = $_.friendlyName
                        ipAddress                                  = $_.ipAddress
                        listLocalOnlyReportChecksum                = $_.listLocalOnlyReportChecksum
                        outdatedReportChecksum                     = $_.outdatedReportChecksum
                        lastCheckInDateTime                        = $_.lastCheckInDateTime
                        fqdn                                       = $_.fqdn
                        ccmServiceName                             = $_.ccmServiceName
                        availableForDeploymentsBasedOnLicenseCount = $_.availableForDeploymentsBasedOnLicenseCount
                        optedIntoDeploymentBasedOnConfig           = $_.optedIntoDeploymentBasedOnConfig
                        software                                   = $_.software
                        groups                                     = $_.groups
                        users                                      = $_.users
                        chocolateyConfigurationFeatures            = $_.chocolateyConfigurationFeatures
                        id                                         = $_.id
                    }
                }
            }
            

        }
       
    }
    
}
