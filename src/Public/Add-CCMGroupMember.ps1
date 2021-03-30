function Add-CCMGroupMember {
    <#
    .SYNOPSIS
    Adds a member to an existing Group in Central Management
    
    .DESCRIPTION
    Add new computers and groups to existing Central Management Groups
    
    .PARAMETER Name
    The group to edit
    
    .PARAMETER Computer
    The computer(s) to add
    
    .PARAMETER Group
    The group(s) to add
    
    .EXAMPLE
    Add-CCMGroupMember -Group 'Newly Imaged' -Computer Lab1,Lab2,Lab3
    
    #>
    [cmdletBinding(HelpUri = "https://chocolatey.org/docs/add-ccmgroup-member")]
    param(
        [parameter(Mandatory = $true)]
        [parameter(ParameterSetName = "Computer")]
        [parameter(ParameterSetName = "Group")]
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
        $Name,
        
        [parameter(Mandatory = $true, ParameterSetName = "Computer")]
        [Parameter(ParameterSetName='Group')]
        [string[]]
        $Computer,

        [parameter(Mandatory = $true ,ParameterSetName = "Group")]
        [string[]]
        $Group
    )

    begin {
        
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        
        $computers = Get-CCMComputer
        $groups = Get-CCMGroup
    
        $ComputerCollection = [System.Collections.Generic.List[psobject]]::new()
        $GroupCollection = [System.Collections.Generic.List[psobject]]::new()

        $id = Get-CCMGroup -Group $name | Select-Object -ExpandProperty Id
        $current = Get-CCMGroup -Id $id | Select-Object *
        $current.computers | ForEach-Object { $ComputerCollection.Add([pscustomobject]@{computerId = "$($_.computerId)" }) }
        
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            { $Computer } {

                foreach ($c in $Computer) {
                    if($c -in $current.computers.computerName){
                        Write-Warning "Skipping $c, already exists"
                    }
                    else {
                        $Cresult = $computers | Where-Object { $_.Name -eq "$c" } | Select-Object  Id
                        $ComputerCollection.Add([pscustomobject]@{computerId = "$($Cresult.Id)" })
                    }
                }

                $processedComputers = $ComputerCollection
                
            }

            'Group' {

                foreach ($g in $Group) {
                    if($g -in $current.groups.subGroupName){
                        Write-Warning "Skipping $g, already exists"
                    }
                    else {
                    $Gresult = $groups | Where-Object { $_.Name -eq "$g" } | Select-Object Id
                    $GroupCollection.Add([pscustomobject]@{subGroupId = "$($Gresult.Id)"})
                }
                }
                $processedGroups = $GroupCollection
            }
        }
        
        $body = @{
            Name        = $Name
            Id          = ($groups | Where-Object { $_.name -eq "$Name" } | Select-Object  -ExpandProperty Id)
            Description = ($groups | Where-Object { $_.name -eq "$Name" } | Select-Object  -ExpandProperty Description)
            Groups      = if (-not $processedGroups) { @() } else { @(,$processedGroups) }
            Computers   = if (-not $processedComputers) { @() } else { @(,$processedComputers) }
        } | ConvertTo-Json -Depth 3

        Write-Verbose $body
        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/CreateOrEdit"
            Method      = "post"
            ContentType = "application/json"
            Body        = $body
            WebSession  = $Session
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
            $successGroup = Get-CCMGroupMember -Group $Name

            [pscustomobject]@{
                Name = $Name
                Description = $successGroup.Description
                Groups = $successGroup.Groups.subGroupName
                Computers = $successGroup.Computers.computerName
            }

        }

        catch {
            throw $_.Exception.Message
        }
    }
}