function Remove-CCMStaleComputer {
    <#
    .SYNOPSIS
    Deletes stale computers from the CCM database.
    
    .DESCRIPTION
    Deletes stale computers from the CCM database.
    
    .PARAMETER ComputerId
    The id of the computer to remove.

    .PARAMETER ComputerName
    The name of the computer to remove.
    
    .PARAMETER Force
    Don't prompt for confirmation.
    
    .EXAMPLE
    Remove-CCMStaleComputer -ComputerId 1

    .EXAMPLE
    Get-CCMStaleComputer -StaleAge 30 | Remove-CCMStaleComputer -Force
    
    .NOTES
    
    #>
    [cmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = "Id")]
    Param(
        [Alias('Id')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [Int[]]
        $ComputerId,

        [Parameter(Mandatory, ParameterSetName = "Name")
        [String[]]
        $ComputerName,

        [Parameter()]
        [Switch]
        $Force
    )

    process {

        switch ($PSCmdlet.ParameterSetName) {

            'Id' {
                $ComputerId | ForEach-Object {
                    if ($Force -and -not $Confirm) {
                        $ConfirmPreference = 'None'
                        if ($PSCmdlet.ShouldProcess("$_", "Remove computer")) {
                            $irmParams = @{
                                Uri         = "$($protocol)://$hostname/api/services/app/Computers/Delete?id=$_"
                                Method      = "DELETE"
                                ContentType = "application/json"
                                WebSession  = $Session
                            }
        
                            $null = Try { 
                                Invoke-RestMethod @irmParams -ErrorAction Stop
                            }
                            catch { $_.Exception.Message }
                    
                        }
                    }
                    else {
                        if ($PSCmdlet.ShouldProcess("$_", "Remove computer")) {
                            $irmParams = @{
                                Uri         = "$($protocol)://$hostname/api/services/app/Computers/Delete?id=$_"
                                Method      = "DELETE"
                                ContentType = "application/json"
                                WebSession  = $Session
                            }
        
                            $null = try {
                                Invoke-RestMethod @irmParams -ErrorAction Stop
                            }
                            catch { $_.Exception.Message }
                        }
                    }
                }
            }
        
            'Name' {
                $ComputerName | ForEach-Object {
                    $id = (Get-CCMComputer -Computer $_).id
                    if ($Force -and -not $Confirm) {
                        $ConfirmPreference = 'None'
                        if ($PSCmdlet.ShouldProcess("$id", "Remove computer")) {
                            $irmParams = @{
                                Uri         = "$($protocol)://$hostname/api/services/app/Computers/Delete?id=$id"
                                Method      = "DELETE"
                                ContentType = "application/json"
                                WebSession  = $Session
                            }
    
                            $null = Try { 
                                Invoke-RestMethod @irmParams -ErrorAction Stop
                            }
                            catch { $_.Exception.Message }
                
                        }
                    }
                    else {
                        if ($PSCmdlet.ShouldProcess("$id", "Remove computer")) {
                            $irmParams = @{
                                Uri         = "$($protocol)://$hostname/api/services/app/Computers/Delete?id=$id"
                                Method      = "DELETE"
                                ContentType = "application/json"
                                WebSession  = $Session
                            }
    
                            $null = try {
                                Invoke-RestMethod @irmParams -ErrorAction Stop
                            }
                            catch { $_.Exception.Message }
                        }
                    }
                }
            }
        }
    }
        
}