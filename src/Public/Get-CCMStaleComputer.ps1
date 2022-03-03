function Get-CCMStaleComputer {
    <#
    .SYNOPSIS
    Retrieves a list of computers that have not checked into Central Management in the given time period.
    
    .DESCRIPTION
    Retrieves a list of computers that have not checked into Central Management in the given time period.
    
    .PARAMETER StaleAge
    The age of stale computers in days.
    
    .EXAMPLE
    Get-CCMStaleComputer -StaleAge 30
    
    .NOTES
    Stale Age defaults to 30 days.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [Int]
        $StaleAge
    )

    process {

        $computers = Get-CCMComputer

        $computers | Where-Object { [DateTime]$_.lastCheckInDateTime -lt $((Get-Date).AddDays(-$StaleAge)) }
    }
}