﻿# Get-CCMGroup

<!-- This documentation is automatically generated from /Get-CCMGroup.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Returns group information for your CCM installation

## Syntax

~~~powershell
Get-CCMGroup [<CommonParameters>]
~~~


~~~powershell
Get-CCMGroup `
  -Group <String[]> [<CommonParameters>]
~~~


~~~powershell
Get-CCMGroup `
  -Id <String[]> [<CommonParameters>]
~~~

## Description

Returns information about the groups created in your CCM Installation


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Get-CCMGroup

~~~

**EXAMPLE 2**

~~~powershell
Get-CCMGroup -Id 1

~~~

**EXAMPLE 3**

~~~powershell
Get-CCMGroup -Group 'Web Servers'

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Group &lt;String[]&gt;
Returns group with the provided name

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Id &lt;String[]&gt;
Returns group withe the provided id

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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Get-CCMGroup -Full`.

View the source for [Get-CCMGroup](/Get-CCMGroup.ps1)
