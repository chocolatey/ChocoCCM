---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Get-CCMComputer

## SYNOPSIS
Returns information about computers in CCM

## SYNTAX

### All (Default)
```
Get-CCMComputer [-All] [<CommonParameters>]
```

### Computer
```
Get-CCMComputer -Computer <String> [<CommonParameters>]
```

### Id
```
Get-CCMComputer -Id <Int32> [<CommonParameters>]
```

## DESCRIPTION
Query for all, or by computer name/id to retrieve information about the system as reported in Central Management

## EXAMPLES

### EXAMPLE 1
```
Get-CCMComputer -All
```

### EXAMPLE 2
```
Get-CCMComputer -Computer web1
```

### EXAMPLE 3
```
Get-CCMComputer -Id 13
```

## PARAMETERS

### -All
Returns all computers

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

### -Computer
Returns the specified computer(s)

```yaml
Type: String
Parameter Sets: Computer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Returns the information for the computer with the specified id

```yaml
Type: Int32
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
