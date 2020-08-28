---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Export-CCMOutdatedSoftwareReport

## SYNOPSIS
Download an outdated Software report from Central Management

## SYNTAX

```
Export-CCMOutdatedSoftwareReport [-Report] <String> [-Type] <String> [-OutputFolder] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Download either a PDF or Excel format report of outdated software from Central Management

## EXAMPLES

### EXAMPLE 1
```
Export-CCMOutdatedSoftwareReport -Report '7/4/2020 6:44:40 PM' -Type PDF -OutputFolder C:\CCMReports
```

## PARAMETERS

### -Report
The report to download

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

### -Type
Specify either PDF or Excel

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFolder
The path to save the file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
