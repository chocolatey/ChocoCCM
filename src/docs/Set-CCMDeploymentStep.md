---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Set-CCMDeploymentStep

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Dumby (Default)
```
Set-CCMDeploymentStep -Deployment <String> -Step <String> [-TargetGroup <String[]>]
 [-ExecutionTimeoutSeconds <String>] [-FailOnError] [-RequireSuccessOnAllComputers]
 [-ValidExitCodes <String[]>] [<CommonParameters>]
```

### Basic
```
Set-CCMDeploymentStep -Deployment <String> -Step <String> [-TargetGroup <String[]>]
 [-ExecutionTimeoutSeconds <String>] [-FailOnError] [-RequireSuccessOnAllComputers]
 [-ValidExitCodes <String[]>] -ChocoCommand <String> -PackageName <String> [<CommonParameters>]
```

### Advanced
```
Set-CCMDeploymentStep -Deployment <String> -Step <String> [-TargetGroup <String[]>]
 [-ExecutionTimeoutSeconds <String>] [-FailOnError] [-RequireSuccessOnAllComputers]
 [-ValidExitCodes <String[]>] -Script <ScriptBlock> [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ChocoCommand
{{ Fill ChocoCommand Description }}

```yaml
Type: String
Parameter Sets: Basic
Aliases:
Accepted values: Install, Upgrade, Uninstall

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Deployment
{{ Fill Deployment Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExecutionTimeoutSeconds
{{ Fill ExecutionTimeoutSeconds Description }}

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

### -FailOnError
{{ Fill FailOnError Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PackageName
{{ Fill PackageName Description }}

```yaml
Type: String
Parameter Sets: Basic
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequireSuccessOnAllComputers
{{ Fill RequireSuccessOnAllComputers Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Script
{{ Fill Script Description }}

```yaml
Type: ScriptBlock
Parameter Sets: Advanced
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Step
{{ Fill Step Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetGroup
{{ Fill TargetGroup Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValidExitCodes
{{ Fill ValidExitCodes Description }}

```yaml
Type: String[]
Parameter Sets: (All)
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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
