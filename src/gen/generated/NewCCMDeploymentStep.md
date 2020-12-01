﻿# New-CCMDeploymentStep

<!-- This documentation is automatically generated from /New-CCMDeploymentStep.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Adds a Deployment Step to a Deployment Plan

## Syntax

~~~powershell
New-CCMDeploymentStep `
  -Deployment <String> `
  -Name <String> `
  [-TargetGroup <String[]>] `
  [-ExecutionTimeoutSeconds <String>] `
  [-FailOnError] `
  [-RequireSuccessOnAllComputers] `
  [-ValidExitCodes <String[]>] `
  -Type <String> `
  -Script <ScriptBlock> [<CommonParameters>]
~~~


~~~powershell
New-CCMDeploymentStep `
  -Deployment <String> `
  -Name <String> `
  [-TargetGroup <String[]>] `
  [-ExecutionTimeoutSeconds <String>] `
  [-FailOnError] `
  [-RequireSuccessOnAllComputers] `
  [-ValidExitCodes <String[]>] `
  -Type <String> `
  -ChocoCommand <String> `
  -PackageName <String> [<CommonParameters>]
~~~


~~~powershell
New-CCMDeploymentStep `
  -Deployment <String> `
  -Name <String> `
  [-TargetGroup <String[]>] `
  [-ExecutionTimeoutSeconds <String>] `
  [-FailOnError] `
  [-RequireSuccessOnAllComputers] `
  [-ValidExitCodes <String[]>] `
  -Type <String> [<CommonParameters>]
~~~

## Description

Adds both Basic and Advanced steps to a Deployment Plan


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup WebServers -Type Basic -ChocoCommand upgrade -PackageName firefox

~~~

**EXAMPLE 2**

~~~powershell
New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script { $process = Get-Process
>> 
>> Foreach($p in $process){
>> Write-Host $p.PID
>> }
>> 
>> Write-Host "end"
>> 
>> }
~~~

**EXAMPLE 3**

~~~powershell
New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script {(Get-Content C:\script.txt)}

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Deployment &lt;String&gt;
The Deployment where the step will be added

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Name &lt;String&gt;
The Name of the step

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -TargetGroup [&lt;String[]&gt;]
The group(s) the step will target

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | @()
Accept Pipeline Input? | false
 
###  -ExecutionTimeoutSeconds [&lt;String&gt;]
How long to wait for the step to timeout. Defaults to 14400 (4 hours)

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | 14400
Accept Pipeline Input? | false
 
###  -FailOnError
Fail the step if there is an error. Defaults to True

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | True
Accept Pipeline Input? | false
 
###  -RequireSuccessOnAllComputers
Ensure all computers are successful before moving to the next step.

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false
 
###  -ValidExitCodes [&lt;String[]&gt;]
Valid exit codes your script can emit. Default values are: '0','1605','1614','1641','3010'

Property               | Value
---------------------- | ----------------------------------
Aliases                | 
Required?              | false
Position?              | named
Default Value          | @('0','1605','1614','1641','3010')
Accept Pipeline Input? | false
 
###  -Type &lt;String&gt;
Either a Basic or Advanced Step

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -ChocoCommand &lt;String&gt;
Select from Install,Upgrade, or Uninstall. Used with a Simple step type.

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -PackageName &lt;String&gt;
The chocolatey package to use with a simple step.

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Script &lt;ScriptBlock&gt;
A scriptblock your Advanced step will use

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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help New-CCMDeploymentStep -Full`.

View the source for [New-CCMDeploymentStep](/New-CCMDeploymentStep.ps1)
