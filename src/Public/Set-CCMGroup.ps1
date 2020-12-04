function Set-CCMGroup {
    <#
    .SYNOPSIS
    Change information about a group in Chocolatey Central Management
    
    .DESCRIPTION
    Change the name or description of a Group in Chocolatey Central Management
    
    .PARAMETER Group
    The Group to edit
    
    .PARAMETER NewName
    The new name of the group
    
    .PARAMETER NewDescription
    The new description of the group
    
    .EXAMPLE
    Set-CCMGroup -Group Finance -Description 'Computers in the finance division'

    .EXAMPLE
    Set-CCMGroup -Group IT -NewName TheBestComputers

    .EXAMPLE
    Set-CCMGroup -Group Test -NewName NewMachineImaged -Description 'Group for freshly imaged machines needing a baseline package pushed to them'
    #>
    [cmdletBinding(HelpUri="https://chocolatey.org/docs/set-ccmgroup")]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMGroup).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Group,

        [Parameter()]
        [string]
        $NewName,

        [parameter()]
        [string]
        $NewDescription
    )

    begin { 
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }$existing = Get-CCMGroup -Group $Group 
    }
    process {

        if ($NewName) {
            $Name = $NewName
        } else {
            $Name = $existing.name
        }

        if ($NewDescription) {
            $Description = $NewDescription
        } else {
            $Description = $existing.description
        }

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/CreateOrEdit"
            Method      = "post"
            ContentType = "application/json"
            Body        = @{
                Id          = $($existing.id)
                Name        = $Name
                Description = $Description
                Groups      = @()
                Computers   = @()
            } | ConvertTo-Json
            WebSession  = $Session
        }
    
        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
    
        catch {
            throw $_.Exception.Message
        }
    }
}