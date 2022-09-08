function Get-CCMOutdatedSoftware {
    <#
    .SYNOPSIS
    Returns all outdated software reported in CCM

    .DESCRIPTION
    Returns all outdated software reported in CCM

    .EXAMPLE
    Get-CCMOutdatedSoftware
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmoutdatedsoftware")]
    param()

    process {
        $r = Get-CCMSoftware | Where-Object { $_.isOutdated -eq $true }
        $r
    }
}
