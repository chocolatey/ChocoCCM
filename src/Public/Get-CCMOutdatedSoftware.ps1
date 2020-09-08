function Get-CCMOutdatedSoftware {

    process {
        $r = Get-CCMSoftware | Where-Object { $_.isOutdated -eq $true}
        $r
    }
}