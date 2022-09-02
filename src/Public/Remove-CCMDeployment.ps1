function Remove-CCMDeployment {
    <#
    .SYNOPSIS
    Removes a deployment plan

    .DESCRIPTION
    Removes the Deployment Plan selected from a Central Management installation

    .PARAMETER Deployment
    The Deployment to  delete

    .EXAMPLE
    Remove-CCMDeployment -Name 'Super Complex Deployment'

    .EXAMPLE
    Remove-CCMDeployment -Name 'Deployment Alpha' -Confirm:$false

    #>
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/removeccmdeployment")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name

                if ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string[]]
        $Deployment
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }

        $deployId = [System.Collections.Generic.List[string]]::new()

        $Deployment | ForEach-Object { $deployId.Add($(Get-CCMDeployment -Name $_ | Select-Object -ExpandProperty Id)) }
    }

    process {
        $deployId | ForEach-Object {
            if ($PSCmdlet.ShouldProcess("$Deployment", "DELETE")) {
                $irmParams = @{
                    Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Delete?Id=$($_)"
                    Method      = "DELETE"
                    ContentType = "application/json"
                }

                Invoke-RestMethod @irmParams
            }
        }
    }
}
