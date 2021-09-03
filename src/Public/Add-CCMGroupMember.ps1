function Add-CCMGroupMember {
    <#
    .SYNOPSIS
    Adds a member to an existing Group in Central Management
    
    .DESCRIPTION
    Add new computers and | or groups to existing Central Management Groups. At least one must be used.
        
    .PARAMETER Name [MANDATORY]
    The group to edit
    
    .PARAMETER Computer [OPTIONAL]
    The computer(s) to add
    
    .PARAMETER Group [OPTIONAL]
    The group(s) to add
    
    .EXAMPLE
    Add-CCMGroupMember -Name 'All Newly Imaged' -Group 'New Laptops' -Computer Lab1,Lab2,Lab3
    Add-CCMGroupMember -Name 'All Newly Imaged' -Computer Lab1,Lab2,Lab3
    Add-CCMGroupMember -Name 'All Newly Imaged' -Group 'New Laptops'
    
    #>
    [cmdletBinding(HelpUri = "https://chocolatey.org/docs/add-ccmgroup-member")]
    param(
        [parameter(Mandatory = $true)]
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
         
        [string]$Computer,

        [string]$Group
    )

    begin {
        
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }

        if(-not($Computer) -and (-not($Group))) { Throw “Please ensure that at least one parameter is used to add member(s): Computer | Group” }
        
        $computers = Get-CCMComputer
        $groups = Get-CCMGroup
    
        $ComputerCollection = [System.Collections.Generic.List[psobject]]::new()
        $GroupCollection = [System.Collections.Generic.List[psobject]]::new()

        $id = Get-CCMGroup -Group $name | Select-Object -ExpandProperty Id
        $current = Get-CCMGroup -Id $id | Select-Object *
    }
   

    process{
        if ([string]::IsNullOrEmpty($Computer)){
                $processedComputers = @()
        }
       
        else {
            
                foreach ($c in $Computer) {
                    if($c -in $current.computers.computerName){
                        Write-Warning "Skipping $c, already exists"
                    }
                    else {
                        $Cresult = $computers | Where-Object { $_.Name -eq "$c" } | Select-Object  Id
                        $ComputerCollection.Add([pscustomobject]@{computerId = "$($Cresult.Id)" })
                    }
                }
            }
         
        #Add any current computers into the array
        $current.computers | ForEach-Object { $ComputerCollection.Add([pscustomobject]@{computerId = "$($_.computerId)" }) }             
        $processedComputers = $ComputerCollection           
            

       if ([string]::IsNullOrEmpty($Group)) {
                $processedGroups = @()
       }
       else {
        
                foreach ($g in $Group) {
                    if($g -in $current.groups.subGroupName){
                        Write-Warning "Skipping $g, already exists"
                    }
                    else {
                        $Gresult = $groups | Where-Object { $_.Name -eq "$g" } | Select-Object Id
                        $GroupCollection.Add([pscustomobject]@{subGroupId = "$($Gresult.Id)"})
                    }
                }
            }
          
       
        #Add any current groups into the array
        $current.groups | ForEach-Object { $GroupCollection.Add([pscustomobject]@{subGroupId = "$($_.subGroupId)" }) }             
        $processedGroups = $GroupCollection           
            
        
        $body = @{
            Name        = $Name
            Id          = ($groups | Where-Object { $_.name -eq "$Name" } | Select-Object  -ExpandProperty Id)
            Description = ($groups | Where-Object { $_.name -eq "$Name" } | Select-Object  -ExpandProperty Description)
            Groups      = $processedGroups
            Computers   = $processedComputers

        } | ConvertTo-Json -Depth 3

        Write-Verbose $body
        write-host $body
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
