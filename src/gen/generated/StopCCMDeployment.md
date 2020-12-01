﻿# Stop-CCMDeployment

<!-- This documentation is automatically generated from /Stop-CCMDeployment.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Stops a running CCM Deployment

## Syntax

~~~powershell
Stop-CCMDeployment `
  [-Deployment <String>] `
  [-WhatIf] `
  [-Confirm] [<CommonParameters>]
~~~

## Description

Stops a deployment current running in Central Management


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Stop-CCMDeployment -Deployment 'Upgrade VLC'

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Deployment [&lt;String&gt;]
The deployment to Stop

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Stop-CCMDeployment -Full`.

View the source for [Stop-CCMDeployment](/Stop-CCMDeployment.ps1)
