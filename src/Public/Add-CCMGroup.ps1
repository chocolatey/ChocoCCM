function Add-CCMGroup {
    <#
    .SYNOPSIS
    Adds a group to Central Management
    
    .DESCRIPTION
    Deployments in Central Management revolve around Groups. Before you can execute a deployment you must define a target group of computers the Deployment will execute on.
    Use this function to create new groups in your Central Management system
    
    .PARAMETER Name
    The name you wish to give the group
    
    .PARAMETER Description
    A short description of the group
    
    .PARAMETER Group
    The group(s) to include as members
    
    .PARAMETER Computer
    The computer(s) to include as members
    
    .EXAMPLE
    Add-CCMGroup -Name PowerShell -Description "I created this via the ChocoCCM module" -Computer pc1,pc2

    .EXAMPLE
    Add-CCMGroup -Name PowerShell -Description "I created this via the ChocoCCM module" -Group Webservers
    #>
    [cmdletBinding(HelpUri="https://chocolatey.org/docs/add-ccmgroup")]
    param(
        [parameter(mandatory = $true)]
        [string]
        $Name,
        
        [parameter()]
        [string]
        $Description,

        [parameter()]
        [string[]]
        $Group,

        [parameter()]
        [string[]]
        $Computer
    )

    begin {

        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        
        $computers = Get-CCMComputer
        $groups = Get-CCMGroup

        $ComputerCollection = [System.Collections.Generic.List[psobject]]::new()
        $GroupCollection = [System.Collections.Generic.List[psobject]]::new()

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

    process {
        $body = @{
            Name        = $Name
            Description = $Description
            Groups      = if (-not $processedGroups) { @() } else { @(,$processedGroups) }
            Computers   = if (-not $processedComputers) { @() } else { @(,$processedComputers) }
            } | ConvertTo-Json

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/CreateOrEdit"
            Method      = "post"
            ContentType = "application/json"
            Body        = $body
            WebSession  = $Session
        }
        
        Write-Verbose $body

        try {
            $response = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
    
        catch {
            throw $_.Exception.Message
        }

        [pscustomobject]@{
            name = $Name
            description = $Description
            groups = $Group
            computers = $Computer
        }
    }

}