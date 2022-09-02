function Get-CCMOutdatedSoftwareReportDetail {
    <#
    .SYNOPSIS
    View detailed information about an Outdated Software Report

    .DESCRIPTION
    Return report details from an Outdated Software Report in Central Management

    .PARAMETER Report
    The report to query

    .EXAMPLE
    Get-CCMOutdatedSoftwareReportDetail -Report '7/4/2020 6:44:40 PM'

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmoutdatedsoftwarereportdetail")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMOutdatedSoftwareReport).creationTime

                if ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string]
        $Report
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {
        $reportId = Get-CCMOutdatedSoftwareReport | Where-Object { $_.creationTime -eq "$Report" } | Select-Object -ExpandProperty id

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/OutdatedReports/GetAllByReportId?reportId=$reportId&sorting=outdatedReport.packageDisplayText%20asc&skipCount=0&maxResultCount=200"
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

        $response.result.items.outdatedReport
    }
}
