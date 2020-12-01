﻿# Remove-CCMGroup

<!-- This documentation is automatically generated from /Remove-CCMGroup.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Removes a CCM group

## Syntax

~~~powershell
Remove-CCMGroup `
  [-Group <String[]>] `
  [-WhatIf] `
  [-Confirm] [<CommonParameters>]
~~~

## Description

Removes a group from Chocolatey Central Management


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Remove-CCMGroup -Group WebServers

~~~

**EXAMPLE 2**

~~~powershell
Remove-CCMGroup -Group WebServer,TestAppDeployment

~~~

**EXAMPLE 3**

~~~powershell
Remove-CCMGroup -Group PilotPool -Confirm:$false

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Group [&lt;String[]&gt;]
The group(s) to delete

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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Remove-CCMGroup -Full`.

View the source for [Remove-CCMGroup](/Remove-CCMGroup.ps1)
