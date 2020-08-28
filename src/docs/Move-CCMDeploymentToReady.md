---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Move-CCMDeploymentToReady

## SYNOPSIS
Moves a  deployment to Ready state

## SYNTAX

```
Move-CCMDeploymentToReady [-Deployment] <String> [<CommonParameters>]
```

## DESCRIPTION
Moves a Deployment to the Ready state so it can start

## EXAMPLES

### EXAMPLE 1
```
Move-CCMDeploymentToReady -Deployment 'Upgrade Outdated VLC'
```

### EXAMPLE 2
```
Move-CCMDeploymenttoReady -Deployment 'Complex Deployment'
```

## PARAMETERS

### -Deployment
The deployment  to  move

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
