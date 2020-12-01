﻿# Set-CCMGroup

<!-- This documentation is automatically generated from /Set-CCMGroup.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Change information about a group in Chocolatey Central Management

## Syntax

~~~powershell
Set-CCMGroup `
  [-Group <String>] `
  [-NewName <String>] `
  [-NewDescription <String>] [<CommonParameters>]
~~~

## Description

Change the name or description of a Group in Chocolatey Central Management


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Set-CCMGroup -Group Finance -Description 'Computers in the finance division'

~~~

**EXAMPLE 2**

~~~powershell
Set-CCMGroup -Group IT -NewName TheBestComputers

~~~

**EXAMPLE 3**

~~~powershell
Set-CCMGroup -Group Test -NewName NewMachineImaged -Description 'Group for freshly imaged machines needing a baseline package pushed to them'

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Group [&lt;String&gt;]
The Group to edit

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 1
Default Value          | 
Accept Pipeline Input? | false
 
###  -NewName [&lt;String&gt;]
The new name of the group

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 2
Default Value          | 
Accept Pipeline Input? | false
 
###  -NewDescription [&lt;String&gt;]
The new description of the group

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 3
Default Value          | 
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Set-CCMGroup -Full`.

View the source for [Set-CCMGroup](/Set-CCMGroup.ps1)
