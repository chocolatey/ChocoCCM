function Stop-CCMDeployment {
    <#
    .SYNOPSIS
    Stops a running CCM Deployment

    .DESCRIPTION
    Stops a deployment current running in Central Management

    .PARAMETER Deployment
    The deployment to Stop

    .EXAMPLE
    Stop-CCMDeployment -Deployment 'Upgrade VLC'

    #>
    [cmdletBinding(ConfirmImpact = "high", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/stopccmdeployment")]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment).Name

                if ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string]
        $Deployment
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }

        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
    }

    process {
        if ($PSCmdlet.ShouldProcess("$Deployment", "CANCEL")) {
            $irmParams = @{
                Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Cancel"
                Method      = "POST"
                ContentType = "application/json"
                Body        = @{ id = "$deployId" } | ConvertTo-Json
                Websession  = $Session
            }

            try {
                $null = Invoke-RestMethod @irmParams -ErrorAction Stop
            }
            catch {
                throw $_.Exception.Message
            }
        }
    }
}
