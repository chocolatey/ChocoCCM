﻿# Set-CCMDeploymentStep

<!-- This documentation is automatically generated from /Set-CCMDeploymentStep.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Modify a Deployment Step of a Central Management Deployment

## Syntax

~~~powershell
Set-CCMDeploymentStep `
  -Deployment <String> `
  -Step <String> `
  [-TargetGroup <String[]>] `
  [-ExecutionTimeoutSeconds <String>] `
  [-FailOnError] `
  [-RequireSuccessOnAllComputers] `
  [-ValidExitCodes <String[]>] [<CommonParameters>]
~~~


~~~powershell
Set-CCMDeploymentStep `
  -Deployment <String> `
  -Step <String> `
  [-TargetGroup <String[]>] `
  [-ExecutionTimeoutSeconds <String>] `
  [-FailOnError] `
  [-RequireSuccessOnAllComputers] `
  [-ValidExitCodes <String[]>] `
  -ChocoCommand <String> `
  -PackageName <String> [<CommonParameters>]
~~~


~~~powershell
Set-CCMDeploymentStep `
  -Deployment <String> `
  -Step <String> `
  [-TargetGroup <String[]>] `
  [-ExecutionTimeoutSeconds <String>] `
  [-FailOnError] `
  [-RequireSuccessOnAllComputers] `
  [-ValidExitCodes <String[]>] `
  -Script <ScriptBlock> [<CommonParameters>]
~~~

## Description

Modify a Deployment Step of a Central Management Deployment


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Set-CCMDeploymentStep -Deployment 'Google Chrome Upgrade' -Step 'Upgrade' -TargetGroup LabPCs -ExecutionTimeoutSeconds 14400 -ChocoCommand Upgrade -PackageName googlechrome

~~~

**EXAMPLE 2**

~~~powershell
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
~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Deployment &lt;String&gt;
The Deployment to modify

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Step &lt;String&gt;
The step to modify

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -TargetGroup [&lt;String[]&gt;]
Set the target group of the deployment

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -ExecutionTimeoutSeconds [&lt;String&gt;]
Modify the execution timeout of the deployment in seconds

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -FailOnError
Set the FailOnError flag for the deployment step

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false
 
###  -RequireSuccessOnAllComputers
Set the RequreSuccessOnAllComputers for the deployment step

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false
 
###  -ValidExitCodes [&lt;String[]&gt;]
Set valid exit codes for the deployment

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -ChocoCommand &lt;String&gt;
For a basic step, set the choco command to execute. Install, Upgrade, or Uninstall

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -PackageName &lt;String&gt;
For a basic step, the choco package to use in the deployment

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Script &lt;ScriptBlock&gt;
For an advanced step, this is a script block of PowerShell code to execute in the step

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Set-CCMDeploymentStep -Full`.

View the source for [Set-CCMDeploymentStep](/Set-CCMDeploymentStep.ps1)
