---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Export-CCMDeploymentDetail

## SYNOPSIS
Downloads a deployment report from Central Management

## SYNTAX

```
Export-CCMDeploymentDetail [[-Deployment] <String>] [-Type] <String> [-OutputFolder] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Downloads a deployment report from Central Management in PDF or Excel format

## EXAMPLES

### EXAMPLE 1
```
Export-CCMDeploymentDetail -Deployment 'Complex' -Type PDF -OutputFolder C:\temp\
```

### EXAMPLE 2
```
Export-CCMDeploymentDetail -Deployment 'Complex -Type Excel -OutputFolder C:\CCMReports
```

## PARAMETERS

### -Deployment
The deployment from which to generate and download a report

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The type  of report, either PDF or Excel

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
The path to save the report too

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
