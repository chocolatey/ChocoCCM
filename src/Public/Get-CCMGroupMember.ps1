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
    [CmdletBinding(HelpUri = "https://chocolatey.org/docs/get-ccmgroup-member")]
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
        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/GetGroupForEdit?id=$Id"
            Method      = "GET"
            ContentType = "application/json"
            WebSession  = $Session
        }

        try {
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        $cCollection = [System.Collections.Generic.List[psobject]]::new()
        $gCollection = [System.Collections.Generic.List[psobject]]::new()

        $record.result.computers | ForEach-Object {
            $cCollection.Add($_)
        }

        $record.result.groups | ForEach-Object {
            $gCollection.Add($_)
        }

        [pscustomobject]@{
            Name        = $record.result.Name
            Description = $record.result.Description
            Groups      = @($gCollection)
            Computers   = @($cCollection)
            CanDeploy   = $record.result.isEligibleForDeployments
        }
    }
}
