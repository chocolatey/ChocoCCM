function Get-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Return information about a CCM Deployment step.

    .DESCRIPTION
    Returns detailed information about Central Management Deployment Steps.

    .PARAMETER InputObject
    Retrieves additional details for the given step.

    .PARAMETER Id
    Returns the Deployment Step with the given Id.

    .PARAMETER IncludeResults
    If set, additionally retrieves the results for the targeted step.

    .EXAMPLE
    Get-CCMDeploymentStep -Id 583 -IncludeResults

    .EXAMPLE
    Get-CCMDeploymentStep -InputObject $step -IncludeResults
    #>
    [CmdletBinding(DefaultParameterSetName = 'IdOnly', HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmdeploymentstep")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'StepObject')]
        [Alias('Step')]
        [psobject]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'IdOnly')]
        [Alias('DeploymentStepId')]
        [long]
        $Id,

        [Parameter()]
        [switch]
        $IncludeResults
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {
        if (-not $Id) {
            $Id = $InputObject.Id
        }

        $params = @{
            Uri        = "${script:Protocol}://${script:Hostname}/api/services/app/DeploymentSteps/GetDeploymentStepForEdit"
            WebSession = $script:Session
            Body       = @{ Id = $Id }
        }

        $result = Invoke-RestMethod @params

        if ($IncludeResults) {
            $result | Select-Object -ExcludeProperty 'deploymentStepComputers' -Property @(
                '*'
                @{
                    Name       = 'deploymentStepComputers'
                    Expression = {
                        $params = @{
                            Uri        = "${script:Protocol}://${script:Hostname}/api/services/app/DeploymentStepComputers/GetAllByDeploymentStepId"
                            WebSession = $script:Session
                            Body       = @{ deploymentStepId = $_.id }
                        }
                        (Invoke-RestMethod @params).result
                    }
                }
            )
        }
        else {
            $result
        }
    }
}
