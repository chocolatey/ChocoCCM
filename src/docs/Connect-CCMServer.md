---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Connect-CCMServer

## SYNOPSIS
Creates a session to a CCM instance

## SYNTAX

```
Connect-CCMServer [-Hostname] <String> -Credential <PSCredential> [-UseSSL] [<CommonParameters>]
```

## DESCRIPTION
Creates a web session cookie used for other cmdlets in the ChocoCCM module

## EXAMPLES

### EXAMPLE 1
```
Connect-CCMServer -Hostname localhost:8090
```

### EXAMPLE 2
```
$cred = Get-Credential ; Connect-CCMServer -Hostname localhost:8090 -Credential $cred
```

## PARAMETERS

### -Hostname
The hostname and port number of your Central Management installation

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The credentials for your Central Management installation.
YOu'll be prompted if left blank

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSSL
{{ Fill UseSSL Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
