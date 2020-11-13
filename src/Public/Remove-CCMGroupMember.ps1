function Remove-CCMGroupMember {
    <#
    .SYNOPSIS
    Remove a member from a Central Management Group
    
    .DESCRIPTION
    Remove a member from a Central Management Group
    
    .PARAMETER Group
    The group you want to remove a member from
    
    .PARAMETER Member
    The member you want to remove
    
    .EXAMPLE
    Remove-CCMGroupMember -Group TestLab -Member TestPC1
    #>
    [cmdletBinding(ConfirmImpact="High",SupportsShouldProcess,HelpUri="https://chocolatey.org/docs/remove-ccmgroup-member")]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMGroup -All).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Group,

        [parameter(Mandatory)]
        [string]
        $Member
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        $id = (Get-CCMGroup -Group $Group).id

        $irmParams  = @{
            Uri = ""
            Method = "DELETE"
            ContentType = "application/json"
            WebSession  = $Session
        }

        try {
            Invoke-RestMethod @irmParams -ErrorAction Stop
        } catch {
            throw $_.Exception.Message
        }
    }
}