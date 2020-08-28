---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# New-CCMDeploymentStep

## SYNOPSIS
Adds a Deployment Step to a Deployment Plan

## SYNTAX

### Advanced
```
New-CCMDeploymentStep -Deployment <String> -Name <String> [-TargetGroup <String[]>]
 [-ExecutionTimeoutSeconds <String>] [-FailOnError] [-RequireSuccessOnAllComputers]
 [-ValidExitCodes <String[]>] -Type <String> -Script <ScriptBlock> [<CommonParameters>]
```

### Basic
```
New-CCMDeploymentStep -Deployment <String> -Name <String> [-TargetGroup <String[]>]
 [-ExecutionTimeoutSeconds <String>] [-FailOnError] [-RequireSuccessOnAllComputers]
 [-ValidExitCodes <String[]>] -Type <String> -ChocoCommand <String> -PackageName <String> [<CommonParameters>]
```

### StepType
```
New-CCMDeploymentStep -Deployment <String> -Name <String> [-TargetGroup <String[]>]
 [-ExecutionTimeoutSeconds <String>] [-FailOnError] [-RequireSuccessOnAllComputers]
 [-ValidExitCodes <String[]>] -Type <String> [<CommonParameters>]
```

## DESCRIPTION
Adds both Basic and Advanced steps to a Deployment Plan

## EXAMPLES

### EXAMPLE 1
```
New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup WebServers -Type Basic -ChocoCommand upgrade -PackageName firefox
```

### EXAMPLE 2
```
New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script { $process = Get-Process
>> 
>> Foreach($p in $process){
>> Write-Host $p.PID
>> }
>> 
>> Write-Host "end"
>> 
>> }
```

### EXAMPLE 3
```
New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script {(Get-Content C:\script.txt)}
```

## PARAMETERS

### -Deployment
The Deployment where the step will be added

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

### -Name
The Name of the step

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
The group(s) the step will target

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExecutionTimeoutSeconds
How long to wait for the step to timeout.
Defaults to 14400 (4 hours)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 14400
Accept pipeline input: False
Accept wildcard characters: False
```

### -FailOnError
Fail the step if there is an error.
Defaults to True

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequireSuccessOnAllComputers
Ensure all computers are successful before moving to the next step.

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

### -ValidExitCodes
Valid exit codes your script can emit.
Default values are: '0','1605','1614','1641','3010'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @('0','1605','1614','1641','3010')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Either a Basic or Advanced Step

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

### -ChocoCommand
Select from Install,Upgrade, or Uninstall.
Used with a Simple step type.

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

### -PackageName
The chocolatey package to use with a simple step.

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

### -Script
A scriptblock your Advanced step will use

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
