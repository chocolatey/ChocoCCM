﻿# Set-CCMNotificationStatus

<!-- This documentation is automatically generated from /Set-CCMNotificationStatus.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Turn notifications on or off in CCM

## Syntax

~~~powershell
Set-CCMNotificationStatus `
  -Enable [<CommonParameters>]
~~~


~~~powershell
Set-CCMNotificationStatus `
  -Disable [<CommonParameters>]
~~~

## Description

Manage your notification settings in Central Management. Currently only supports On, or Off


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Set-CCMNotificationStatus -Enable

~~~

**EXAMPLE 2**

~~~powershell
Set-CCMNotificationStatus -Disable

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Enable
Enables notifications

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | False
Accept Pipeline Input? | false
 
###  -Disable
Disables notifications

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | False
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Set-CCMNotificationStatus -Full`.

View the source for [Set-CCMNotificationStatus](/Set-CCMNotificationStatus.ps1)
