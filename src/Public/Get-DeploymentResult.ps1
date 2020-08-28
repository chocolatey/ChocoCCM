function Get-DeploymentResult {
    [cmdletBinding()]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id

    }

    process {

        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/GetAllPagedByDeploymentPlanId?resultFilter=Success%2CFailed%2CUnreachable%2CInconclusive%2CReady%2CActive%2CCancelled%2CUnknown%2CDraft&deploymentPlanId=$deployId&sorting=planOrder%20asc&skipCount=0&maxResultCount=10"
            Method = "GET"
            ContentType = "application/json"
            WebSession = $Session
        }

        try {
            $records = Invoke-RestMethod @irmParams -ErrorAction Stop
            $records.result.items
        }
        catch{
            throw $_.Exception.Message
        }
    }
}
