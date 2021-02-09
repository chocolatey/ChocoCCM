function Remove-CCMGroupMember {
    <#
    .SYNOPSIS
    Remove a member from a Central Management Group
    
    .DESCRIPTION
    Remove a member from a Central Management Group
    
    .PARAMETER Group
    The group you want to remove a member from
    
    .PARAMETER GroupMember
    The group(s) to remove from the group

    .PARAMETER ComputerMember
    The computer(s) to remove from the group
    
    .EXAMPLE
    Remove-CCMGroupMember -Group TestLab -ComputerMember TestPC1

    .EXAMPLE
    Remove-CCMGroupMember -Group TestLab -ComputerMember Test1,Test2 -GroupMember SecondLab
    #>
    [cmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://chocolatey.org/docs/remove-ccmgroup-member")]
    param(
        [parameter(Mandatory)]
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

        [parameter()]
        [string[]]
        $GroupMember,

        [parameter()]
        [string[]]
        $ComputerMember
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        $currentMembers = Get-CCMGroupMember -Group $Group
        $G = Get-CCMGroup -Group $Group
        $currentMembers | Add-Member -MemberType NoteProperty -Name Id -Value $G.Id

        foreach ($c in $ComputerMember) {
            $currentMembers.Computers = @($($currentMembers.Computers | Where-Object { $_.ComputerName -ne $c }))
        }

        foreach ($g in $GroupMember) {
            $currentMembers.Groups = @($($currentMembers.Groups | Where-Object { $_.subGroupName -ne $g }))
        }

        if (-not $currentMembers.Groups) {
            $currentMembers.Groups = @()
        }

        if (-not $currentMembers.Computers) {
            $currentMembers.Computers = @()
        }

        $body = $currentMembers | ConvertTo-Json -Depth 3

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/CreateOrEdit"
            Method      = "POST"
            ContentType = "application/json"
            Body        = $body
            WebSession  = $Session
        }
                
        Write-Verbose $body
        try {
            $result = Invoke-RestMethod @irmParams -ErrorAction Stop
            [pscustomobject]@{
                Status            = $result.success
                Group             = $Group
                AffectedComputers = $ComputerMember
                AffectedGroups    = $GroupMember
            }
        }
        catch {
            throw $_.Exception.Message
        }
        
    }

}