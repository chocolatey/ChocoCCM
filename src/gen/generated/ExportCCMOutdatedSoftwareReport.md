﻿# Export-CCMOutdatedSoftwareReport

<!-- This documentation is automatically generated from /Export-CCMOutdatedSoftwareReport.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Download an outdated Software report from Central Management. This file will be saved to the OutputFolder specified

## Syntax

~~~powershell
Export-CCMOutdatedSoftwareReport `
  -Report <String> `
  -Type <String> `
  -OutputFolder <String> [<CommonParameters>]
~~~

## Description

Download either a PDF or Excel format report of outdated software from Central Management to the OutputFolder specified


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Export-CCMOutdatedSoftwareReport -Report '7/4/2020 6:44:40 PM' -Type PDF -OutputFolder C:\CCMReports

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Report &lt;String&gt;
The report to download

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 1
Default Value          | 
Accept Pipeline Input? | false
 
###  -Type &lt;String&gt;
Specify either PDF or Excel

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 2
Default Value          | 
Accept Pipeline Input? | false
 
###  -OutputFolder &lt;String&gt;
The path to save the file

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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Export-CCMOutdatedSoftwareReport -Full`.

View the source for [Export-CCMOutdatedSoftwareReport](/Export-CCMOutdatedSoftwareReport.ps1)
