function Move-CCMDeploymentToReady {
    <#
    .SYNOPSIS
    Moves a  deployment to Ready state

    .DESCRIPTION
    Moves a Deployment to the Ready state so it can start

    .PARAMETER Deployment
    The deployment  to  move

    .EXAMPLE
    Move-CCMDeploymentToReady -Deployment 'Upgrade Outdated VLC'

    .EXAMPLE
    Move-CCMDeploymenttoReady -Deployment 'Complex Deployment'

    #>
    [CmdletBinding(HelpUri = "https://chocolatey.org/docs/move-ccmdeployment-to-ready")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = Get-CCMDeployment -All

                if ($WordToComplete) {
                    $r.name.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r.name
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

        $id = (Get-CCMDeployment -Name $Deployment).id
    }

    process {
        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/MoveToReady"
            Method      = "POST"
            ContentType = "application/json"
            Body        = @{ id = "$id" } | ConvertTo-Json
            WebSession  = $Session
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
