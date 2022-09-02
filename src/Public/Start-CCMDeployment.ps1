function Start-CCMDeployment {
    <#
    .SYNOPSIS
    Starts a deployment

    .DESCRIPTION
    Starts the specified deployment in Central  Management

    .PARAMETER Deployment
    The deployment  to  start

    .EXAMPLE
    Start-CCMDeployment -Deployment 'Upgrade Outdated VLC'

    .EXAMPLE
    Start-CCMDeployment -Deployment 'Complex Deployment'
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/startccmdeployment")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = Get-CCMDeployment

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
            Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Start"
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
