﻿# Start-CCMDeployment

<!-- This documentation is automatically generated from /Start-CCMDeployment.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Starts a deployment

## Syntax

~~~powershell
Start-CCMDeployment `
  -Deployment <String> [<CommonParameters>]
~~~

## Description

Starts the specified deployment in Central  Management


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Start-CCMDeployment -Deployment 'Upgrade Outdated VLC'

~~~

**EXAMPLE 2**

~~~powershell
Start-CCMDeployment -Deployment 'Complex Deployment'

~~~ 

## Inputs

None

## Outputs

None

## Parameters
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Start-CCMDeployment -Full`.

View the source for [Start-CCMDeployment](/Start-CCMDeployment.ps1)
