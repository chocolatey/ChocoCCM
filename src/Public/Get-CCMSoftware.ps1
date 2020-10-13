Function Get-CCMSoftware {
    <#
    .SYNOPSIS
    Returns information about software tracked inside of CCM
    
    .DESCRIPTION
    Return information about each piece of software managed across all of your estate inside Central Management
    
    .PARAMETER Software
    Return information about a specific piece of software by friendly name

    .PARAMETER Package
    Return information about a specific package
    
    .PARAMETER Id
    Return information about a specific piece of software by id
    
    .EXAMPLE
    Get-CCMSoftware

    .EXAMPLE
    Get-CCMSoftware -Software 'VLC Media Player'

    .EXAMPLE
    Get-CCMSoftware -Package vlc

    .EXAMPLE
    Get-CCMSoftware -Id 37
    
    .NOTES
    #>
    [cmdletBinding(DefaultParameterSetName = "All")]
    Param(
            
        [Parameter(Mandatory, ParameterSetName = "Software")]
        [string]
        $Software,
        
        [Parameter(Mandatory, ParameterSetName = "Package")]
        [string]
        $Package,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id

    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Software/GetAll" -WebSession $Session -UseBasicParsing
        } 
        
        Switch ($PSCmdlet.ParameterSetName) {

            "Software" {
                $softwareId = $records.result.items | Where-Object { $_.name -eq "$Software" } | Select-Object -ExpandProperty Id

                $irmParams = @{
                    WebSession = $Session
                    Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$softwareID&skipCount=0&maxResultCount=500"
                }
                
                $records = Invoke-RestMethod @irmParams
                $records.result.items

            }

            "Package" {
                $packageId = $records.result.items | Where-Object { $_.packageId -eq "$Package" } | Select-Object -ExpandProperty id

                $packageId | ForEach-Object {
                    $irmParams = @{
                        WebSession = $Session
                        Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$($_)&skipCount=0&maxResultCount=500"
                    }
                
                    $records = Invoke-RestMethod @irmParams
                    $records.result.items
                }
            }

            "Id" {

                $irmParams = @{
                    WebSession = $Session
                    Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$Id&skipCount=0&maxResultCount=500"
                }
                $records = Invoke-RestMethod @irmParams
                $records.result.items
            }

            default {
                $records.result.items
            }

        }
       
    }
}
