﻿# Disable-CCMDeployment

<!-- This documentation is automatically generated from /Disable-CCMDeployment.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Archive a CCM Deployment. This will move a Deployment to the Archived Deployments section in the Central Management Web UI.

## Syntax

~~~powershell
Disable-CCMDeployment `
  [-Deployment <String>] `
  [-WhatIf] `
  [-Confirm] [<CommonParameters>]
~~~

## Description

Moves a deployment in Central Management to the archive. This Deployment will no longer be available for use.


## Aliases

`Archive-CCMDeployment`


## Examples

 **EXAMPLE 1**

~~~powershell
Disable-CCMDeployment -Deployment 'Upgrade VLC'

~~~

**EXAMPLE 2**

~~~powershell
Archive-CCMDeployment -Deployment 'Upgrade VLC'

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Deployment [&lt;String&gt;]
The deployment to archive

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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Disable-CCMDeployment -Full`.

View the source for [Disable-CCMDeployment](/Disable-CCMDeployment.ps1)
