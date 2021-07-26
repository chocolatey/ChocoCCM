function Remove-CCMStaleComputer {
    <#
    .SYNOPSIS
    Deletes stale computers from the CCM database.
    
    .DESCRIPTION
    Deletes stale computers from the CCM database.
    
    .PARAMETER ComputerId
    The id of the computer to remove.
    
    .PARAMETER Force
    Don't prompt for confirmation.
    
    .EXAMPLE
    Remove-CCMStaleComputer -ComputerId 1

    .EXAMPLE
    Get-CCMStaleComputer -StaleAge 30 | Remove-CCMStaleComputer -Force
    
    .NOTES
    
    #>
    [cmdletBinding(SupportsShouldProcess)]
    Param(
        [Alias('Id')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]]
        $ComputerId,

        [Parameter()]
        [Switch]
        $Force
    )

    process {

        $ComputerId | ForEach-Object {
            if ($Force -and -not $Confirm) {
                $ConfirmPreference = 'None'
                if ($PSCmdlet.ShouldProcess("$_", "Remove computer")) {
                    $irmParams = @{
                        Uri = "$($protocol)://$hostname/api/services/app/Computers/Delete?id=$_"
                        Method = "DELETE"
                        ContentType = "application/json"
                        WebSession = $Session
                    }

                    Invoke-RestMethod @irmParams
            
                }
            }
            else {
                if ($PSCmdlet.ShouldProcess("$_", "Remove computer")) {
                    $irmParams = @{
                        Uri = "$($protocol)://$hostname/api/services/app/Computers/Delete?id=$_"
                        Method = "DELETE"
                        ContentType = "application/json"
                        WebSession = $Session
                    }

                    Invoke-RestMethod @irmParams
                }
            }
        }
    }
}