﻿# Get-CCMSoftware

<!-- This documentation is automatically generated from /Get-CCMSoftware.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Returns information about software tracked inside of CCM

## Syntax

~~~powershell
Get-CCMSoftware `
  -Software <String> [<CommonParameters>]
~~~


~~~powershell
Get-CCMSoftware `
  -Package <String> [<CommonParameters>]
~~~


~~~powershell
Get-CCMSoftware `
  -Id <Int32> [<CommonParameters>]
~~~

## Description

Return information about each piece of software managed across all of your estate inside Central Management


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Get-CCMSoftware

~~~

**EXAMPLE 2**

~~~powershell
Get-CCMSoftware -Software 'VLC Media Player'

~~~

**EXAMPLE 3**

~~~powershell
Get-CCMSoftware -Package vlc

~~~

**EXAMPLE 4**

~~~powershell
Get-CCMSoftware -Id 37

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Software &lt;String&gt;
Return information about a specific piece of software by friendly name

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Package &lt;String&gt;
Return information about a specific package

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Id &lt;Int32&gt;
Return information about a specific piece of software by id

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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Get-CCMSoftware -Full`.

View the source for [Get-CCMSoftware](/Get-CCMSoftware.ps1)
