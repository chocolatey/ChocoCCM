function Get-CCMGroup {
    <#
    .SYNOPSIS
    Returns group information for your CCM installation
    
    .DESCRIPTION
    Returns information about the groups created in your CCM Installation
    
    .PARAMETER Group
    Returns group with the provided name
    
    .PARAMETER Id
    Returns group withe the provided id
    
    .EXAMPLE
    Get-CCMGroup

    .EXAMPLE
    Get-CCMGroup -Id 1

    .EXAMPLE
    Get-CCMGroup -Group 'Web Servers'
    
    #>
    [cmdletBinding(DefaultParameterSetName="default",HelpUri="https://chocolatey.org/docs/get-ccmgroup")]
    param(

        [parameter(Mandatory, ParameterSetName = "Group")]
        [string[]]
        $Group,

        [parameter(Mandatory, ParameterSetName = "Id")]
        [String[]]
        $Id
    )

    begin {
        If (-not $Session) {

            throw "Unauthenticated! Please run Connect-CCMServer first"

        }

    }
    process {
        if (-not $Id) {
            $records = Invoke-RestMethod -Method Get -Uri "$($protocol)://$hostname/api/services/app/Groups/GetAll" -WebSession $Session
            #$records = Invoke-We -Uri http://$Hostname/api/services/app/Groups/GetAll -WebSession $Session -UseBasicParsing
        } 
        
        Switch ($PSCmdlet.ParameterSetName) {

            "Group" {

                $records.result | Where-Object { $_.name -in $Group }

            }

            "Id" {
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Groups/GetGroupForEdit?Id=$Id" -WebSession $Session
                $records.result
            }

            default {

                $records.result

            }

        }

    }
}