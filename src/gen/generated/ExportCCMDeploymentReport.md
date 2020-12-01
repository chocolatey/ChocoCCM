﻿# Export-CCMDeploymentReport

<!-- This documentation is automatically generated from /Export-CCMDeploymentReport.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Downloads a deployment report from Central Management. This will be saved in the path you specify for OutputFolder

## Syntax

~~~powershell
Export-CCMDeploymentReport `
  [-Deployment <String>] `
  -Type <String> `
  -OutputFolder <String> [<CommonParameters>]
~~~

## Description

Downloads a deployment report from Central Management in PDF or Excel format. The file is saved to the OutputFolder


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Export-CCMDeploymentReport -Deployment 'Complex' -Type PDF -OutputFolder C:\temp\

~~~

**EXAMPLE 2**

~~~powershell
Export-CCMDeploymentReport -Deployment 'Complex -Type Excel -OutputFolder C:\CCMReports

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Deployment [&lt;String&gt;]
The deployment from which to generate and download a report

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 1
Default Value          | 
Accept Pipeline Input? | false
 
###  -Type &lt;String&gt;
The type  of report, either PDF or Excel

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 2
Default Value          | 
Accept Pipeline Input? | false
 
###  -OutputFolder &lt;String&gt;
The path to save the report too

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 3
Default Value          | 
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Export-CCMDeploymentReport -Full`.

View the source for [Export-CCMDeploymentReport](/Export-CCMDeploymentReport.ps1)
