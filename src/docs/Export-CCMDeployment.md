---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Export-CCMDeployment

## SYNOPSIS
Exports a Deployment to CliXML

## SYNTAX

```
Export-CCMDeployment [-Deployment] <String> [-DeploymentStepsOnly] [-OutFile] <String> [-AllowClobber]
 [<CommonParameters>]
```

## DESCRIPTION
Adds ability to export a deployment as cli-xml.
Useful for backup/source control of deployments

## EXAMPLES

### EXAMPLE 1
```
Export-CCMDeployment -Deployment TestDeployment -OutFile C:\temp\testdeployment.xml
```

### EXAMPLE 2
```
Export-CCMDeployment -Deployment UpgradeChrome -OutFile C:\temp\upgradechrome_ccmdeployment.xml -AllowClobber
```

## PARAMETERS

### -Deployment
The CCM Deployment to Export

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

### -DeploymentStepsOnly
Only export a deployment's steps

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
The xml file to save the deployment as

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

### -AllowClobber
Allow a file to be overwritten if it already exists

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
