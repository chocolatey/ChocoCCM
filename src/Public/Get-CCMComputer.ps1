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
    [cmdletBinding(DefaultParameterSetName = "All",HelpUri="https://chocolatey.org/docs/get-ccmcomputer")]
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

                    [pscustomobject]$records.result | Where-Object { $_.name -match "$c" } 
                
                }

            }

            "Id" {

                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Computers/GetComputerForEdit?Id=$Id" -WebSession $Session
                $records

            }

            default {
                
                $records.result
    
            }
            

        }
       
    }
    
}
