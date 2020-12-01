﻿# Remove-CCMGroupMember

<!-- This documentation is automatically generated from /Remove-CCMGroupMember.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Remove a member from a Central Management Group

## Syntax

~~~powershell
Remove-CCMGroupMember `
  -Group <String> `
  -Member <String> `
  [-WhatIf] `
  [-Confirm] [<CommonParameters>]
~~~

## Description

Remove a member from a Central Management Group


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Remove-CCMGroupMember -Group TestLab -Member TestPC1

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Group &lt;String&gt;
The group you want to remove a member from

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 1
Default Value          | 
Accept Pipeline Input? | false
 
###  -Member &lt;String&gt;
The member you want to remove

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 2
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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Remove-CCMGroupMember -Full`.

View the source for [Remove-CCMGroupMember](/Remove-CCMGroupMember.ps1)
