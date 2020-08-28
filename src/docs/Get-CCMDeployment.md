---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Get-CCMDeployment

## SYNOPSIS
Return information about a CCM Deployment

## SYNTAX

### All (Default)
```
Get-CCMDeployment [-All] [<CommonParameters>]
```

### Name
```
Get-CCMDeployment -Name <String> [<CommonParameters>]
```

### Id
```
Get-CCMDeployment -Id <String> [<CommonParameters>]
```

## DESCRIPTION
Returns detailed information about Central Management Deployment Plans

## EXAMPLES

### EXAMPLE 1
```
Get-CCMDeployment -All
```

### EXAMPLE 2
```
Get-CCMDeployment -Name Bob
```

### EXAMPLE 3
```
Get-CCMDeployment -Id 583
```

## PARAMETERS

### -All
Returns all Deployment Plans

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Returns the named Deployment Plan

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Returns the Deployment Plan with the give Id

```yaml
Type: String
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
