function Get-DeploymentResult {
    <#
    .SYNOPSIS
    Return the result of a Central Management Deployment
    
    .DESCRIPTION
    Return the result of a Central Management Deployment
    
    .PARAMETER Deployment
    The Deployment for which to return information
    
    .EXAMPLE
    Get-CCMDeploymentResult -Name 'Google Chrome Upgrade'
    
    #>
    [cmdletBinding(HelpUri="https://chocolatey.org/docs/get-deployment-result")]
    param(
        [Parameter(Mandatory)]
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
