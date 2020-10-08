function Get-CCMOutdatedPackageMember {
    [cmdletBinding()]
    param(
        [parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMSoftware -All | Where-Object { $_.isOutdated -eq $true }).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Software,

        [parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMSoftware -All | Where-Object { $_.isOutdated -eq $true }).packageId
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Package
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        if ($Software) {
            $id = Get-CCMSoftware -Software $Software | Select-Object -ExpandProperty softwareId

        }

        if ($Package) {
            $id = Get-CCMSoftware -Package $Package | Select-Object -ExpandProperty softwareId

        }

        $id | Foreach-Object {
            $irmParams = @{
                Uri         = "$($protocol)://$hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$($_)&skipCount=0&maxResultCount=100"
                Method      = "GET"
                ContentType = "application/json"
                WebSession  = $Session
            }

            try {
                $record = Invoke-RestMethod @irmParams -ErrorAction Stop
            }
            catch {
                $_.Exception.Message
            }

            $record.result.items | Foreach-Object {
                [pscustomobject]@{
                    softwareId     = $_.softwareId
                    software       = $_.software.name
                    packageName    = $_.software.packageId
                    packageVersion = $_.software.packageVersion
                    name           = $_.computer.name
                    friendlyName   = $_.computer.friendlyName
                    ipaddress      = $_.computer.ipaddress
                    fqdn           = $_.computer.fqdn
                    computerid     = $_.computer.id
                
                }
                
            }
        }
    }
}