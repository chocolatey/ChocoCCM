function Set-CCMDeploymentStep {
    [cmdletBinding(DefaultParameterSetName="Dumby")]
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
