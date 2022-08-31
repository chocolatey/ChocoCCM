function Get-CCMOutdatedSoftware {
    <#
    .SYNOPSIS
    Returns all outdated software reported in CCM

    .DESCRIPTION
    Returns all outdated software reported in CCM

    .EXAMPLE
    Get-CCMOutdatedSoftware
    #>
    [CmdletBinding(HelpUri = "https://chocolatey.org/docs/get-ccmoutdated-software")]
    param()

    process {
        $r = Get-CCMSoftware | Where-Object { $_.isOutdated -eq $true }
        $r
    }
}
