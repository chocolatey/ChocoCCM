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

    .PARAMETER ExecutionTimeout
    How long to wait, in seconds, for the step to timeout. Defaults to 14400 (4 hours)

    .PARAMETER MachineContactTimeout
    How long to wait, in minutes, for computers to check in to start the deployment before timing out.
    Defaults to 0 (no timeout).

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
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/newccmdeploymentstep")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment).Name

                if ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string]
        $Deployment,

        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMGroup).Name

                if ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string[]]
        $TargetGroup = @(),

        [Parameter()]
        [Alias('ExecutionTimeoutSeconds', 'ExecutionTimeoutInSeconds')]
        [string]
        $ExecutionTimeout = '14400',

        [Parameter()]
        [Alias('MachineContactTimeoutInMinutes', 'MachineContactTimeoutMinutes')]
        [string]
        $MachineContactTimeout = 0,

        [Parameter()]
        [switch]
        $FailOnError = $true,

        [Parameter()]
        [switch]
        $RequireSuccessOnAllComputers = $false,

        [Parameter()]
        [string[]]
        $ValidExitCodes = @('0', '1605', '1614', '1641', '3010'),

        [Parameter(Mandatory, ParameterSetName = "StepType")]
        [Parameter(Mandatory, ParameterSetName = "Basic")]
        [Parameter(Mandatory, ParameterSetName = "Advanced")]
        [ValidateSet('Basic', 'Advanced')]
        [string]
        $Type,

        [Parameter(Mandatory, ParameterSetName = "Basic")]
        [ValidateSet('Install', 'Upgrade', 'Uninstall')]
        [string]
        $ChocoCommand,

        [Parameter(Mandatory, ParameterSetName = "Basic")]
        [string]
        $PackageName,

        [Parameter(Mandatory, ParameterSetName = "Advanced")]
        [scriptblock]
        $Script
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Basic' {
                $Body = @{
                    name                           = $Name
                    deploymentPlanId               = (Get-CCMDeployment -Name $Deployment).id
                    deploymentStepGroups           = @(
                        Get-CCMGroup -Group $TargetGroup | Select-Object -Property @(
                            @{ Name = "groupId"; Expression = { $_.id } }
                            @{ Name = "groupName"; Expression = { $_.name } }
                        )
                    )
                    executionTimeoutInSeconds      = $ExecutionTimeout
                    machineContactTimeoutInMinutes = $MachineContactTimeout
                    requireSuccessOnAllComputers   = $RequireSuccessOnAllComputers
                    failOnError                    = $FailOnError
                    validExitCodes                 = $ValidExitCodes -join ','
                    script                         = "{0}|{1}" -f @($ChocoCommand.ToLower(), $PackageName)
                } | ConvertTo-Json -Depth 3

                $Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/CreateOrEdit"
            }
            'Advanced' {
                $Body = @{
                    Name                         = "$Name"
                    DeploymentPlanId             = "$(Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id)"
                    DeploymentStepGroups         = @(
                        Get-CCMGroup -Group $TargetGroup | Select-Object Name, Id | ForEach-Object {
                            [pscustomobject]@{ groupId = $_.id; groupName = $_.name }
                        }
                    )
                    ExecutionTimeoutInSeconds    = "$ExecutionTimeoutSeconds"
                    RequireSuccessOnAllComputers = "$RequireSuccessOnAllComputers"
                    failOnError                  = "$FailOnError"
                    validExitCodes               = "$($validExitCodes -join ',')"
                    script                       = "$($Script.ToString())"
                } | ConvertTo-Json -Depth 3

                $Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/CreateOrEditPrivileged"
            }
        }

        $irmParams = @{
            Uri         = $Uri
            Method      = "POST"
            ContentType = "application/json"
            WebSession  = $Session
            Body        = $Body
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
