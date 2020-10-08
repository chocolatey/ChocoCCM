---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Get-CCMSoftware

## SYNOPSIS
Returns information about software tracked inside of CCM

## SYNTAX

### All (Default)
```
Get-CCMSoftware [<CommonParameters>]
```

### Software
```
Get-CCMSoftware -Software <String> [<CommonParameters>]
```

### Package
```
Get-CCMSoftware -Package <String> [<CommonParameters>]
```

### Id
```
Get-CCMSoftware -Id <Int32> [<CommonParameters>]
```

## DESCRIPTION
Return information about each piece of software managed across all of your estate inside Central Management

## EXAMPLES

### EXAMPLE 1
```
Get-CCMSoftware -All
```

### EXAMPLE 2
```
Get-CCMSoftware -Software 'VLC Media Player'
```

### EXAMPLE 3
```
Get-CCMSoftware -Package vlc
```

### EXAMPLE 4
```
Get-CCMSoftware -Id 37
```

## PARAMETERS

### -Software
Return information about a specific piece of software by friendly name

```yaml
Type: String
Parameter Sets: Software
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Package
Return information about a specific package

```yaml
Type: String
Parameter Sets: Package
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Return information about a specific piece of software by id

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
