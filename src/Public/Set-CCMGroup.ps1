function Set-CCMGroup {
    [cmdletBinding()]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMGroup -All).Name
                

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