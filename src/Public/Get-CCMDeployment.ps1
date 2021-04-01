function Get-CCMDeployment {
    <#
    .SYNOPSIS
    Return information about a CCM Deployment.

    .DESCRIPTION
    Returns detailed information about Central Management Deployment Plans.

    .PARAMETER Name
    Returns the named Deployment Plan.

    .PARAMETER Id
    Returns the Deployment Plan with the given Id.

    .PARAMETER IncludeStepResults
    If set, additionally retrieves the results for each step of the deployment.

    .EXAMPLE
    Get-CCMDeployment

    .EXAMPLE
    Get-CCMDeployment -Name Bob

    .EXAMPLE
    Get-CCMDeployment -Id 583 -IncludeStepResults
    #>
    [CmdletBinding(DefaultParameterSetname = "default", HelpUri="https://chocolatey.org/docs/get-ccmdeployment")]
    param(

        [Parameter(ParameterSetName = "Name", Mandatory)]
        [string]
        $Name,

        [Parameter(ParameterSetName = "Id", Mandatory)]
        [string]
        $Id,

        [Parameter(ParameterSetName = "Name")]
        [Parameter(ParameterSetName = "Id")]
        [switch]
        $IncludeStepResults
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetAll" -WebSession $Session
        }

        switch ($PSCmdlet.ParameterSetName) {

            'Name' {

                $queryId = $records.result | Where-Object { $_.Name -eq "$Name"} | Select-Object -ExpandProperty Id
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit?Id=$queryId" -WebSession $Session

                if ($IncludeStepResults) {
                    $result = $records.result.deploymentPlan
                    $result.deploymentSteps = $result.deploymentSteps | Get-CCMDeploymentStep -IncludeResults

                    $result
                }
                else {
                    $records.result.deploymentPlan
                }

            }

            'Id' {
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit?Id=$id" -WebSession $Session

                if ($IncludeStepResults) {
                    $result = $records.result.deploymentPlan
                    $result.deploymentSteps = $result.deploymentSteps | Get-CCMDeploymentStep -IncludeResults

                    $result
                }
                else {
                    $records.result.deploymentPlan
                }
            }

            default {
                $records.result
            }

        }
    }
}
