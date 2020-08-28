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
    [cmdletBinding(ConfirmImpact = "High", SupportsShouldProcess)]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All)
                

                If ($WordToComplete) {
                    $r.Name.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r.Name
                }
            }
        )]
        [string]
        $Deployment,

        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $d = (Get-CCMDeployment -Name $($FakeBoundParams.Deployment)).id
                $idSteps = (Get-CCMDeployment -Id $d).deploymentSteps.Name

                If ($WordToComplete) {
                    $idSteps.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $idSteps
                }
            }
        )]
        [string]
        $Step

    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
        $deploymentSteps = Get-CCMDeployment -Id $deployId | Select-Object deploymentSteps
        $stepId = $deploymentSteps.deploymentSteps | Where-Object { $_.Name -eq "$Step"} | Select -ExpandProperty id

    }
    process {
    
        if ($PSCmdlet.ShouldProcess("$Step", "DELETE")) {
            $irmParams = @{
                Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/Delete?Id=$stepId"
                Method = "DELETE"
                ContentType = "application/json"
                WebSession = $Session
            }

            $null = Invoke-RestMethod @irmParams
        }
    }
}