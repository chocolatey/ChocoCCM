function Remove-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Removes a deployment plan

    .DESCRIPTION
    Removes the Deployment Plan selected from a Central Management installation

    .PARAMETER Deployment
    The Deployment to  remove a step from

    .PARAMETER Step
    The Step to remove

    .EXAMPLE
    Remove-CCMDeploymentStep -Name 'Super Complex Deployment' -Step 'Kill web services'

    .EXAMPLE
    Remove-CCMDeploymentStep -Name 'Deployment Alpha' -Step 'Copy Files' -Confirm:$false

    #>
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/removeccmdeploymentstep")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment)

                if ($WordToComplete) {
                    $r.Name.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r.Name
                }
            }
        )]
        [string]
        $Deployment,

        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $d = (Get-CCMDeployment -Name $($FakeBoundParams.Deployment)).id
                $idSteps = (Get-CCMDeployment -Id $d).deploymentSteps.Name

                if ($WordToComplete) {
                    $idSteps.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $idSteps
                }
            }
        )]
        [string]
        $Step
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }

        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
        $deploymentSteps = Get-CCMDeployment -Id $deployId | Select-Object deploymentSteps
        $stepId = $deploymentSteps.deploymentSteps | Where-Object { $_.Name -eq "$Step" } | Select-Object -ExpandProperty id
    }

    process {
        if ($PSCmdlet.ShouldProcess("$Step", "DELETE")) {
            $irmParams = @{
                Uri         = "$($protocol)://$hostname/api/services/app/DeploymentSteps/Delete?Id=$stepId"
                Method      = "DELETE"
                ContentType = "application/json"
                WebSession  = $Session
            }

            $null = Invoke-RestMethod @irmParams
        }
    }
}
