﻿# Remove-CCMDeploymentStep

<!-- This documentation is automatically generated from /Remove-CCMDeploymentStep.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Removes a deployment plan

## Syntax

~~~powershell
Remove-CCMDeploymentStep `
  -Deployment <String> `
  -Step <String> `
  [-WhatIf] `
  [-Confirm] [<CommonParameters>]
~~~

## Description

Removes the Deployment Plan selected from a Central Management installation


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Remove-CCMDeploymentStep -Name 'Super Complex Deployment' -Step 'Kill web services'

~~~

**EXAMPLE 2**

~~~powershell
Remove-CCMDeploymentStep -Name 'Deployment Alpha' -Step 'Copy Files' -Confirm:$false

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Deployment &lt;String&gt;
The Deployment to  remove a step from

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 1
Default Value          | 
Accept Pipeline Input? | false
 
###  -Step &lt;String&gt;
The Step to remove

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 2
Default Value          | 
Accept Pipeline Input? | false
 
###  -WhatIf
Property               | Value
---------------------- | -----
Aliases                | wi
Required?              | false
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Confirm
Property               | Value
---------------------- | -----
Aliases                | cf
Required?              | false
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Remove-CCMDeploymentStep -Full`.

View the source for [Remove-CCMDeploymentStep](/Remove-CCMDeploymentStep.ps1)
