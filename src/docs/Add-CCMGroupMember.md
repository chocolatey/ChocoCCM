---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Add-CCMGroupMember

## SYNOPSIS
Adds a member to an existing Group in CCM

## SYNTAX

### Group
```
Add-CCMGroupMember [-Name <String>] [-Group <String[]>] [<CommonParameters>]
```

### Computer
```
Add-CCMGroupMember [-Name <String>] -Computer <String[]> [<CommonParameters>]
```

## DESCRIPTION
Add new computers and groups to existing Central Management Groups

## EXAMPLES

### EXAMPLE 1
```
An example
```

## PARAMETERS

### -Name
The group to edit

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computer
The computer(s) to add

```yaml
Type: String[]
Parameter Sets: Computer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
The group(s) to add

```yaml
Type: String[]
Parameter Sets: Group
Aliases:

Required: False
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
General notes

## RELATED LINKS
