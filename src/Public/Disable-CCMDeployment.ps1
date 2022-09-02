function Disable-CCMDeployment {
    <#
    .SYNOPSIS
    Archive a CCM Deployment. This will move a Deployment to the Archived Deployments section in the Central Management Web UI.

    .DESCRIPTION
    Moves a deployment in Central Management to the archive. This Deployment will no longer be available for use.

    .PARAMETER Deployment
    The deployment to archive

    .EXAMPLE
    Disable-CCMDeployment -Deployment 'Upgrade VLC'

    .EXAMPLE
    Archive-CCMDeployment -Deployment 'Upgrade VLC'

    #>
    [Alias('Archive-CCMDeployment')]
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/disableccmdeployment")]
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
        if ($PSCmdlet.ShouldProcess("$Deployment", "ARCHIVE")) {
            $irmParams = @{
                Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Archive"
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
