function Get-CCMComputer {
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
    [CmdletBinding(DefaultParameterSetName = "All", HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmcomputer")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Computer")]
        [string[]]
        $Computer,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id
    )

    begin {
        if (-not $Session) {
            throw "Unauthenticated! Please run Connect-CCMServer first"
        }
    }

    process {
        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Computers/GetAll" -WebSession $Session
        }

        switch ($PSCmdlet.ParameterSetName) {
            "Computer" {
                foreach ($c in $computer) {
                    [pscustomobject]$records.result | Where-Object { $_.name -eq $c }
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
