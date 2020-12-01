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
    [cmdletBinding(HelpUri="https://chocolatey.org/docs/add-ccmgroup-member")]
    param(
        [parameter(Mandatory = $true)]
        [parameter(ParameterSetName = "Computer")]
        [parameter(ParameterSetName = "Group")]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMGroup).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Name,
        
        [parameter(Mandatory = $true, ParameterSetName = "Computer")]
        [string[]]
        $Computer,

        [parameter(ParameterSetName = "Group")]
        [string[]]
        $Group
    )

    begin {
        
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        
        $computers = Get-CCMComputer
        $groups = Get-CCMGroup
    
        $ComputerCollection = [System.Collections.Generic.List[psobject]]::new()
        $GroupCollection = [System.Collections.Generic.List[psobject]]::new()

        $id  = Get-CCMGroup -Group $name | Select-Object -ExpandProperty Id
        $current = Get-CCMGroup -Id $id| Select-Object computers
        $current.computers | ForEach-Object { $ComputerCollection.Add($($_.computerId))}
        #$current.id | % {$ComputerCollection.Add($_)}
        
    }

    process {

        switch($PSCmdlet.ParameterSetName){
            'Computer' {

                foreach ($c in $Computer) {
                    $Cresult = $computers | Where-Object { $_.Name -eq "$c" } | Select-Object -ExpandProperty Id
                    $ComputerCollection.Add($Cresult)
                }

                $processedComputers = @($ComputerCollection | ForEach-Object { [pscustomobject]@{ computerId = "$_"}})
                
            }

            'Group' {

                foreach ($g in $Group) {
                    $Gresult = $groups | Where-Object { $_.Name -eq "$g" } | Select-Object -ExpandProperty Id
                    $GroupCollection.Add($Gresult)
                }
                    $processedGroups = @($GroupCollection | ForEach-Object { [pscustomobject]@{ computerId ="$_" }})
                }
            }
        

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/CreateOrEdit"
            Method      = "post"
            ContentType = "application/json"
            Body        = @{
                Name        = $Name
                Id          = ($groups | Where-Object { $_.name -eq "$Name"} | Select-Object  -ExpandProperty Id)
                Description = ($groups | Where-Object { $_.name -eq "$Name"} | Select-Object  -ExpandProperty Description)
                Groups      = $processedGroups
                Computers   = $processedComputers
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