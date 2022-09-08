function Get-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    List all Outdated Software Reports generated in Central Management

    .DESCRIPTION
    List all Outdated Software Reports generated in Central Management

    .EXAMPLE
    Get-CCMOutdatedSoftwareReport
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmoutdatedsoftwarereport")]
    param()

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {
        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Reports/GetAllPaged?reportTypeFilter=1"
            Method      = "GET"
            ContentType = "application/json"
            WebSession  = $Session
        }

        try {
            $response = Invoke-RestMethod @irmParams
        }
        catch {
            throw $_.Exception.Message
        }

        $response.result.items | ForEach-Object {
            [pscustomobject]@{
                reportType   = $_.report.reportType -as [String]
                creationTime = $_.report.creationTime -as [String]
                id           = $_.report.id -as [string]
            }
        }
    }
}
