---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Invoke-ArchiveCCMDeployment

## SYNOPSIS
Archive a CCM Deployment

## SYNTAX

```
Invoke-ArchiveCCMDeployment [[-Deployment] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Moves a deployment in Central Management to the archive

## EXAMPLES

### EXAMPLE 1
```
Invoke-ArchiveCCMDeployment -Deployment 'Upgrade VLC'
```

### EXAMPLE 2
```
Archive-CCMDeployment -Deployment 'Upgrade VLC'
```

## PARAMETERS

### -Deployment
The deployment to archive

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

## RELATED LINKS
