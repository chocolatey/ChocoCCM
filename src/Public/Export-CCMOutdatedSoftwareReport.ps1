function Export-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    Download an outdated Software report from Central Management. This file will be saved to the OutputFolder specified

    .DESCRIPTION
    Download either a PDF or Excel format report of outdated software from Central Management to the OutputFolder specified

    .PARAMETER Report
    The report to download

    .PARAMETER Type
    Specify either PDF or Excel

    .PARAMETER OutputFolder
    The path to save the file

    .EXAMPLE
    Export-CCMOutdatedSoftwareReport -Report '7/4/2020 6:44:40 PM' -Type PDF -OutputFolder C:\CCMReports

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/exportccmoutdatedsoftwarereport")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMOutdatedSoftwareReport).creationTime

                of ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string]
        $Report,

        [Parameter(Mandatory)]
        [ValidateSet('PDF', 'Excel')]
        [string]
        $Type,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string]
        $OutputFolder
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {
        $reportId = Get-CCMOutdatedSoftwareReport |
            Where-Object { $_.creationTime -eq "$Report" } |
            Select-Object -ExpandProperty id

        $irmParams = @{
            Method      = "GET"
            ContentType = "application/json"
            WebSession  = $Session
        }

        switch ($Type) {
            'PDF' {
                $url = "$($protocol)://$hostname/api/services/app/OutdatedReports/GetOutdatedSoftwareToPdf?reportId=$reportId"
            }
            'Excel' {
                $url = "$($protocol)://$hostname/api/services/app/OutdatedReports/GetOutdatedSoftwareToExcel?reportId=$reportId"
            }
        }

        $irmParams.Add('Uri', "$url")

        try {
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop
            $fileName = $record.result.fileName
            $fileType = $record.result.fileType
            $fileToken = $record.result.fileToken
        }
        catch {
            throw $_.Exception
        }

        $downloadParams = @{
            Uri         = "$($protocol)://$hostname/File/DownloadTempFile?fileType=$fileType&fileToken=$fileToken&fileName=$fileName"
            OutFile     = "$($OutputFolder)\$($fileName)"
            WebSession  = $Session
            Method      = "GET"
            ContentType = $fileType
        }

        try {
            $dl = Invoke-RestMethod @downloadParams -ErrorAction Stop
        }
        catch {
            $_.ErrorDetails
        }
    }
}
