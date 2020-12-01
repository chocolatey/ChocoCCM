﻿# Get-CCMOutdatedSoftwareMember

<!-- This documentation is automatically generated from /Get-CCMOutdatedSoftwareMember.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Returns computers with the requested outdated software. To see outdated software information use Get-CCMOutdatedSoftware

## Syntax

~~~powershell
Get-CCMOutdatedSoftwareMember `
  [-Software <String>] `
  [-Package <String>] [<CommonParameters>]
~~~

## Description

Returns the computers with the requested outdated software. To see outdated software information use Get-CCMOutdatedSoftware


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Get-CCMOutdatedSoftwareMember -Software 'VLC Media Player'

~~~

**EXAMPLE 2**

~~~powershell
Get-CCMOutdatedSoftwareMember -Package vlc

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Software [&lt;String&gt;]
The software to query. Software here refers to what would show up in Programs and Features on a machine.
Example: If you have VLC installed, this shows as 'VLC Media Player' in Programs and Features.

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 1
Default Value          | 
Accept Pipeline Input? | false
 
###  -Package [&lt;String&gt;]
This is the Chocolatey package name to search for.

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 2
Default Value          | 
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Get-CCMOutdatedSoftwareMember -Full`.

View the source for [Get-CCMOutdatedSoftwareMember](/Get-CCMOutdatedSoftwareMember.ps1)
