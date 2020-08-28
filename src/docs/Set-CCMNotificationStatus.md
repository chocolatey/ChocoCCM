---
external help file: ChocoCCM-help.xml
Module Name: ChocoCCM
online version:
schema: 2.0.0
---

# Set-CCMNotificationStatus

## SYNOPSIS
Turn notifications on or off in CCM

## SYNTAX

### Enabled
```
Set-CCMNotificationStatus [-Enable] [<CommonParameters>]
```

### Disabled
```
Set-CCMNotificationStatus [-Disable] [<CommonParameters>]
```

## DESCRIPTION
Manage your notification settings in Central Management.
Currently only supports On, or Off

## EXAMPLES

### EXAMPLE 1
```
Set-CCMNotificationStatus -Enable
```

### EXAMPLE 2
```
Set-CCMNotificationStatus -Disable
```

## PARAMETERS

### -Enable
Enables notifications

```yaml
Type: SwitchParameter
Parameter Sets: Enabled
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disable
Disables notifications

```yaml
Type: SwitchParameter
Parameter Sets: Disabled
Aliases:

Required: True
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
