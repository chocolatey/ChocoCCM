function Remove-CCMStaleDeployment {
    <#
    .SYNOPSIS
    Removes stale CCM Deployments
    
    .DESCRIPTION
    Remove stale deployments from CCM based on their age and run status.
    
    .PARAMETER Age
    The age in days to prune
    
    .EXAMPLE
    Remove-StaleCCMDeployment -Age 30   
        
    #>
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [string]
        $Age
    )

    begin {

    }

    process {
        <#
            Bad States:
            Unknown = 0
            Pending = 2
            Failed = 8
        #>
        $badStates = @(0,2,8)
        if ($PSCmdlet.ShouldProcess("$Deployment", "DELETE")) {
            Get-CCMDeployment -All | Where-Object { $_.CreationDate -ge (Get-Date).AddDays(-$Age) -and $null -eq $_.StartDateTimeUtc -and $_.Result -in $badStates} | Remove-CCMDeployment
        }
    }

}