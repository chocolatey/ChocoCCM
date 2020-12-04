function New-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Adds a Deployment Step to a Deployment Plan
    
    .DESCRIPTION
    Adds both Basic and Advanced steps to a Deployment Plan
    
    .PARAMETER Deployment
    The Deployment where the step will be added
    
    .PARAMETER Name
    The Name of the step
    
    .PARAMETER TargetGroup
    The group(s) the step will target
    
    .PARAMETER ExecutionTimeoutSeconds
    How long to wait for the step to timeout. Defaults to 14400 (4 hours)
    
    .PARAMETER FailOnError
    Fail the step if there is an error. Defaults to True
    
    .PARAMETER RequireSuccessOnAllComputers
    Ensure all computers are successful before moving to the next step.
    
    .PARAMETER ValidExitCodes
    Valid exit codes your script can emit. Default values are: '0','1605','1614','1641','3010'
    
    .PARAMETER Type
    Either a Basic or Advanced Step
    
    .PARAMETER ChocoCommand
    Select from Install,Upgrade, or Uninstall. Used with a Simple step type.

    .PARAMETER PackageName
    The chocolatey package to use with a simple step.

    .PARAMETER Script
    A scriptblock your Advanced step will use

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup WebServers -Type Basic -ChocoCommand upgrade -PackageName firefox

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script { $process = Get-Process
>> 
>> Foreach($p in $process){
>> Write-Host $p.PID
>> }
>> 
>> Write-Host "end"
>> 
>> }

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script {(Get-Content C:\script.txt)}
    
    #>
    [cmdletBinding(HelpUri="https://chocolatey.org/docs/new-ccmdeployment-step")]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMDeployment).Name
                

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
        [string]
        $Name,

        [parameter()]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMGroup).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string[]]
        $TargetGroup = @(),

        [parameter()]
        [string]
        $ExecutionTimeoutSeconds = '14400',

        [parameter()]
        [switch]
        $FailOnError = $true,

        [parameter()]
        [switch]
        $RequireSuccessOnAllComputers = $false,

        [parameter()]
        [string[]]
        $ValidExitCodes = @('0','1605','1614','1641','3010'),

        [parameter(Mandatory,ParameterSetName="StepType")]
        [parameter(Mandatory,ParameterSetName="Basic")]
        [parameter(Mandatory,ParameterSetName="Advanced")]
        [ValidateSet('Basic','Advanced')]
        [string]
        $Type,

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
    }
    process {

        switch($PSCmdlet.ParameterSetName){
            'Basic' {
                $Body = @{
                    Name = "$Name"
                    DeploymentPlanId = "$(Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id)"
                    DeploymentStepGroups = @(Get-CCMGroup -Group $TargetGroup | Select-Object Name,Id | ForEach-Object { [pscustomobject]@{groupId = $_.id ; groupName = $_.name}})
                    ExecutionTimeoutInSeconds = "$ExecutionTimeoutSeconds"
                    RequireSuccessOnAllComputers = "$RequireSuccessOnAllComputers"
                    failOnError = "$FailOnError"
                    validExitCodes = "$($validExitCodes -join ',')"
                    script = "$($ChocoCommand.ToLower())|$($PackageName)"
                    
                } | ConvertTo-Json -Depth 3

                $Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/CreateOrEdit"


            }

            'Advanced' {
                $Body = @{
                    Name = "$Name"
                    DeploymentPlanId = "$(Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id)"
                    DeploymentStepGroups = @(Get-CCMGroup -Group $TargetGroup | Select-Object Name,Id | ForEach-Object { [pscustomobject]@{groupId = $_.id ; groupName = $_.name}})
                    ExecutionTimeoutInSeconds = "$ExecutionTimeoutSeconds"
                    RequireSuccessOnAllComputers = "$RequireSuccessOnAllComputers"
                    failOnError = "$FailOnError"
                    validExitCodes = "$($validExitCodes -join ',')"
                    script = "$($Script.ToString())"
                } | ConvertTo-Json -Depth 3

                $Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/CreateOrEditPrivileged"

                
            }
        }

        $irmParams = @{
            Uri = "$($Uri)"
            Method = "POST"
            ContentType = "application/json"
            WebSession = $Session
            Body = $Body
            
        }

        try{
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch{
            throw $_.Exception.Message
        }

    }
}