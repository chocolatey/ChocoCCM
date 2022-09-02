function Set-CCMNotificationStatus {
    <#
    .SYNOPSIS
    Turn notifications on or off in CCM

    .DESCRIPTION
    Manage your notification settings in Central Management. Currently only supports On, or Off

    .PARAMETER Enable
    Enables notifications

    .PARAMETER Disable
    Disables notifications

    .EXAMPLE
    Set-CCMNotificationStatus -Enable

    .EXAMPLE
    Set-CCMNotificationStatus -Disable

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/setccmnotificationstatus")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Enabled")]
        [switch]
        $Enable,

        [Parameter(Mandatory, ParameterSetName = "Disabled")]
        [switch]
        $Disable
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Enabled' {
                $status = $true
            }
            'Disabled' {
                $status = $false
            }
        }

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Notification/UpdateNotificationSettings"
            Method      = "PUT"
            ContentType = "application/json"
            WebSession  = $Session
            Body        = @{
                receiveNotifications = $status
                notifications        = @(
                    @{
                        name         = "App.NewUserRegistered"
                        isSubscribed = $true
                    }
                )
            } | ConvertTo-Json
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
