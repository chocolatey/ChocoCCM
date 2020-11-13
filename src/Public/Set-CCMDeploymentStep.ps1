function Set-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Modify a Deployment Step of a Central Management Deployment
    
    .DESCRIPTION
    Modify a Deployment Step of a Central Management Deployment
    
    .PARAMETER Deployment
    The Deployment to modify
    
    .PARAMETER Step
    The step to modify
    
    .PARAMETER TargetGroup
    Set the target group of the deployment
    
    .PARAMETER ExecutionTimeoutSeconds
    Modify the execution timeout of the deployment in seconds
    
    .PARAMETER FailOnError
    Set the FailOnError flag for the deployment step
    
    .PARAMETER RequireSuccessOnAllComputers
    Set the RequreSuccessOnAllComputers for the deployment step
    
    .PARAMETER ValidExitCodes
    Set valid exit codes for the deployment
    
    .PARAMETER ChocoCommand
    For a basic step, set the choco command to execute. Install, Upgrade, or Uninstall
    
    .PARAMETER PackageName
    For a basic step, the choco package to use in the deployment
    
    .PARAMETER Script
    For an advanced step, this is a script block of PowerShell code to execute in the step
    
    .EXAMPLE
    Set-CCMDeploymentStep -Deployment 'Google Chrome Upgrade' -Step 'Upgrade' -TargetGroup LabPCs -ExecutionTimeoutSeconds 14400 -ChocoCommand Upgrade -PackageName googlechrome

    .EXAMPLE
    $stepParams = @{
        Deployment = 'OS Version'
        Step = 'Gather Info'
        TargetGroup = 'US-East servers'
        Script = { $data = Get-WMIObject win32_OperatingSystem
                    [pscustomobject]@{
                        Name = $data.caption
                        Version = $data.version
                    }
        }
    }

    Set-CCMDeploymentStep @stepParams
    #>
    [cmdletBinding(DefaultParameterSetName="Dumby",HelpUri="https://chocolatey.org/docs/set-ccmdeployment-step")]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
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
        $Step,

        [parameter()]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMGroup -All).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string[]]
        $TargetGroup,

        [parameter()]
        [string]
        $ExecutionTimeoutSeconds,

        [parameter()]
        [switch]
        $FailOnError,

        [parameter()]
        [switch]
        $RequireSuccessOnAllComputers,

        [parameter()]
        [string[]]
        $ValidExitCodes,

        [parameter(Mandatory,ParameterSetName="Basic")]
        [ValidateSet('Install','Upgrade','Uninstall')]
        [string]
        $ChocoCommand,

        [parameter(Mandatory,ParameterSetName="Basic")]
        [string]
        $PackageName,

        [parameter(Mandatory,ParameterSetName="Advanced")]
        [scriptblock]
        $Script
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
        $deploymentSteps = Get-CCMDeployment -Id $deployId | Select-Object deploymentSteps
        $stepId = $deploymentSteps.deploymentSteps | Where-Object { $_.Name -eq "$Step"} | Select -ExpandProperty id



        $existingstepsParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/GetDeploymentStepForView?Id=$stepId"
            Method = "Get"
            ContentType = "application/json"
            WebSession = $Session
        }
        
        try{
            $existingsteps = Invoke-RestMethod @existingstepsParams -Erroraction Stop
        } catch {
            throw $_.Exception.Message
        }

        $existingsteps = $existingsteps.result.deploymentStep
        $existingsteps

    }

    process {

        #So many if statements, so little time
        foreach($param in $PSBoundParameters){

            $param.Name
            $param.Value
            #$existingsteps.$($param.Key) = $param.Value
        }

        #$existingsteps
    }



}
