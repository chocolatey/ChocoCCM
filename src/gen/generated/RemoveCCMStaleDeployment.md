﻿# Remove-CCMStaleDeployment

<!-- This documentation is automatically generated from /Remove-CCMStaleDeployment.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Removes stale CCM Deployments

## Syntax

~~~powershell
Remove-CCMStaleDeployment `
  -Age <String> `
  [-WhatIf] `
  [-Confirm] [<CommonParameters>]
~~~

## Description

Remove stale deployments from CCM based on their age and run status.


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Remove-StaleCCMDeployment -Age 30

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Age &lt;String&gt;
The age in days to prune

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 1
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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Remove-CCMStaleDeployment -Full`.

View the source for [Remove-CCMStaleDeployment](/Remove-CCMStaleDeployment.ps1)
