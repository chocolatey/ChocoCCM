function Get-CCMRole {
    <#
    .SYNOPSIS
    Get roles available in Chococlatey Central Management

    .DESCRIPTION
    Return information about roles available in Chocolatey Central Management

    .PARAMETER Name
    The name of a role to query

    .EXAMPLE
    Get-CCMRole

    .EXAMPLE
    Get-CCMRole -Name CCMAdmin
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmrole")]
    param(
        [Parameter(ParameterSetName = "Name")]
        [string]
        $Name
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {
        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Role/GetRoles?permission="
            Method      = "GET"
            ContentType = "application/json"
            WebSession  = $Session
        }

        try {
            $response = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Name' {
                $response.result.items | Where-Object { $_.name -eq $Name }
            }
            default {
                $response.result.items
            }
        }
    }
}
