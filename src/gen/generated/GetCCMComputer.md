﻿# Get-CCMComputer

<!-- This documentation is automatically generated from /Get-CCMComputer.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Returns information about computers in CCM

## Syntax

~~~powershell
Get-CCMComputer [<CommonParameters>]
~~~


~~~powershell
Get-CCMComputer `
  -Computer <String[]> [<CommonParameters>]
~~~


~~~powershell
Get-CCMComputer `
  -Id <Int32> [<CommonParameters>]
~~~

## Description

Query for all, or by computer name/id to retrieve information about the system as reported in Central Management


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Get-CCMComputer

~~~

**EXAMPLE 2**

~~~powershell
Get-CCMComputer -Computer web1

~~~

**EXAMPLE 3**

~~~powershell
Get-CCMComputer -Id 13

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Computer &lt;String[]&gt;
Returns the specified computer(s)

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Id &lt;Int32&gt;
Returns the information for the computer with the specified id

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 0
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Get-CCMComputer -Full`.

View the source for [Get-CCMComputer](/Get-CCMComputer.ps1)
