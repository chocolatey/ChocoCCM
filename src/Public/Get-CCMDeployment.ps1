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

    .EXAMPLE
    Get-CCMDeployment

    .EXAMPLE
    Get-CCMDeployment -Name Bob

    .EXAMPLE
    Get-CCMDeployment -Id 583
    #>
    [CmdletBinding(DefaultParameterSetname = "default", HelpUri="https://chocolatey.org/docs/get-ccmdeployment")]
    param(

        [Parameter(ParameterSetName = "Name", Mandatory)]
        [string]
        $Name,

        [Parameter(ParameterSetName = "Id", Mandatory)]
        [string]
        $Id
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

            }

            'Id' {
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetDeploymentPlanForEdit?Id=$id" -WebSession $Session

            default {
                $records.result
            }

        }
    }
}
