function Get-CCMDeployment {
    <#
    .SYNOPSIS
    Return information about a CCM Deployment
    
    .DESCRIPTION
    Returns detailed information about Central Management Deployment Plans
    
    .PARAMETER All
    Returns all Deployment Plans
    
    .PARAMETER Name
    Returns the named Deployment Plan
    
    .PARAMETER Id
    Returns the Deployment Plan with the give Id
    
    .EXAMPLE
    Get-CCMDeployment -All
    
    .EXAMPLE
    Get-CCMDeployment -Name Bob

    .EXAMPLE
    Get-CCMDeployment -Id 583
    #>
    [cmdletBinding(DefaultParameterSetName="All",HelpUri="https://chocolatey.org/docs/get-ccmdeployment")]
    param(
        [parameter(ParameterSetName="All",Mandatory)]
        [switch]
        $All,

        [parameter(ParameterSetName="Name",Mandatory)]
        [string]
        $Name,

        [Parameter(ParameterSetName="Id",Mandatory)]
        [string]
        $Id
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetAll" -WebSession $Session
        } 

        switch($PSCmdlet.ParameterSetName){
            'All' {
                $records.result
            }

            'Name' {
                
                $queryId = $records.result | Where-Object { $_.Name -eq "$Name"} | Select-Object -ExpandProperty Id
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetDeploymentPlanForView?Id=$queryId" -WebSession $Session
                $records.result.deploymentPlan

            }

            'Id' {
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetDeploymentPlanForView?Id=$id" -WebSession $Session
                $records.result.deploymentPlan
            }
        }
    }
}