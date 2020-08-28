---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Add-CCMGroup

## SYNOPSIS
Adds a group to Central Management

## SYNTAX

```
Add-CCMGroup [-Name] <String> [[-Description] <String>] [[-Group] <String[]>] [[-Computer] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Adds a group to Central Management via its REST Api

## EXAMPLES

### EXAMPLE 1
```
Add-CCMGroup -Name PowerShell -Description "I created this via the ChocoCCM module" -Computer pc1,pc2
```

### EXAMPLE 2
```
Add-CCMGroup -Name PowerShell -Description "I created this via the ChocoCCM module" -Group Webservers
```

## PARAMETERS

### -Name
The name of the group

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

### -Description
A short description of the group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
The group(s) to include as members

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computer
The computer(s) to include as members

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
