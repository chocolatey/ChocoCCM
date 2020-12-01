﻿# Connect-CCMServer

<!-- This documentation is automatically generated from /Connect-CCMServer.ps1 using GenerateDocs.ps1. Contributions are welcome at the original location(s). -->

Creates a session to a central management instance

## Syntax

~~~powershell
Connect-CCMServer `
  -Hostname <String> `
  -Credential <PSCredential> `
  [-UseSSL] [<CommonParameters>]
~~~

## Description

Creates a web session cookie used for other functions in the ChocoCCM module


## Aliases

None

## Examples

 **EXAMPLE 1**

~~~powershell
Connect-CCMServer -Hostname localhost:8090

~~~

**EXAMPLE 2**

~~~powershell
$cred = Get-Credential ; Connect-CCMServer -Hostname localhost:8090 -Credential $cred

~~~ 

## Inputs

None

## Outputs

None

## Parameters

###  -Hostname &lt;String&gt;
The hostname and port number of your Central Management installation

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | 1
Default Value          | 
Accept Pipeline Input? | false
 
###  -Credential &lt;PSCredential&gt;
The credentials for your Central Management installation. You'll be prompted if left blank

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | true
Position?              | named
Default Value          | 
Accept Pipeline Input? | false
 
###  -UseSSL
Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false
 
### &lt;CommonParameters&gt;

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .



[[Function Reference|HelpersReference]]

***NOTE:*** This documentation has been automatically generated from `Import-Module "ChocoCCM" -Force; Get-Help Connect-CCMServer -Full`.

View the source for [Connect-CCMServer](/Connect-CCMServer.ps1)
