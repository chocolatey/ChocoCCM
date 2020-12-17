function Get-CCMDeploymentStep {
    [CmdletBinding()]
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
