---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Get-CCMGroup

## SYNOPSIS
Returns group information for your CCM installation

## SYNTAX

### All (Default)
```
Get-CCMGroup [-All] [<CommonParameters>]
```

### Group
```
Get-CCMGroup -Group <String[]> [<CommonParameters>]
```

### Id
```
Get-CCMGroup -Id <String[]> [<CommonParameters>]
```

## DESCRIPTION
Returns information about the groups created in your CCM Installation

## EXAMPLES

### EXAMPLE 1
```
Get-CCMGroup -All
```

### EXAMPLE 2
```
Get-CCMGroup -Id 1
```

### EXAMPLE 3
```
Get-CCMGroup -Group 'Web Servers'
```

## PARAMETERS

### -All
Returns all groups

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

### -Group
Returns group with the provided name

```yaml
Type: String[]
Parameter Sets: Group
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Returns group withe the provided id

```yaml
Type: String[]
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
