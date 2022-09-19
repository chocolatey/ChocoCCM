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
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/removeccmgroupmember")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMGroup -All).Name

                if ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $r
                }
            }
        )]
        [string]
        $Group,

        [Parameter()]
        [string[]]
        $GroupMember,

        [Parameter()]
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
        $computers = Get-CCMComputer
        $groups = Get-CCMGroup

        foreach ($c in $ComputerMember) {
            $cId = $computers | Where-Object { $_.Name -eq $c } | Select-Object -ExpandProperty Id
            if (-not $cId) {
                Write-Warning "No computer with the name $c was found, cannot remove it from the group"
                continue
            }

            $currentMembers.Computers = @($currentMembers.Computers | Where-Object { $_.computerId -ne $cId })
        }

        foreach ($g in $GroupMember) {
            $gId = $groups | Where-Object { $_.Name -eq $g } | Select-Object -ExpandProperty Id
            if (-not $gId) {
                Write-Warning "No group with the name $g was found, cannot remove it from the group"
                continue
            }

            $currentMembers.Groups = @($currentMembers.Groups | Where-Object { $_.subGroupId -ne $g })
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
