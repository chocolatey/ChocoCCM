function New-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    Create a new Outdated Software Report in Central Management
    
    .DESCRIPTION
    Create a new Outdated Software Report in Central Management
    
    .EXAMPLE
    New-CCMOutdatedSoftwareReport
    
    .NOTES
    Creates a new report named with a creation date timestamp in UTC format
    #>
    [cmdletBinding()]
    param()

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {
        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/OutdatedReports/Create"
            Method = "POST"
            ContentType = 'application/json'
            WebSession = $Session
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}