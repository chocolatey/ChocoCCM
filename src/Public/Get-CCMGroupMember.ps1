function Get-CCMGroupMember {
    <#
    .SYNOPSIS
    Returns information about a CCM group's members

    .DESCRIPTION
    Return detailed group information from Chocolatey Central Management

    .PARAMETER Group
    The Group to query

    .EXAMPLE
    Get-CCMGroupMember -Group "WebServers"

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmgroupmember")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMGroup -All).Name

                if ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string]
        $Group
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {
        $Id = (Get-CCMGroup -Group $Group).Id
        $result = Get-CCMGroup -Id $Id

        [pscustomobject]@{
            Id          = $result.Id
            Name        = $result.Name
            Description = $result.Description
            Groups      = @($result.Groups | Where-Object { $_ })
            Computers   = @($result.Computers | Where-Object { $_ })
            CanDeploy   = $result.isEligibleForDeployments
        }
    }
}
