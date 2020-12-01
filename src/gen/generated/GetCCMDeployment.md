﻿# Get-CCMDeployment

<!-- This documentation is automatically generated from /Get-CCMDeployment.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Return information about a CCM Deployment

## Syntax

~~~powershell
Get-CCMDeployment [<CommonParameters>]
~~~


~~~powershell
Get-CCMDeployment `
  -Name <String> [<CommonParameters>]
~~~


~~~powershell
Get-CCMDeployment `
  -Id <String> [<CommonParameters>]
~~~

## Description

Returns detailed information about Central Management Deployment Plans


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Get-CCMDeployment

~~~

**EXAMPLE 2**

~~~powershell
Get-CCMDeployment -Name Bob

~~~

**EXAMPLE 3**

~~~powershell
Get-CCMDeployment -Id 583

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Name &lt;String&gt;
Returns the named Deployment Plan

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -Id &lt;String&gt;
Returns the Deployment Plan with the give Id

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

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Get-CCMDeployment -Full`.

View the source for [Get-CCMDeployment](/Get-CCMDeployment.ps1)
