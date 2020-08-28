function Add-CCMGroup {
    <#
    .SYNOPSIS
    Adds a group to Central Management
    
    .DESCRIPTION
    Adds a group to Central Management via its REST Api
    
    .PARAMETER Name
    The name of the group
    
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
    
    .NOTES
    
    #>
    [cmdletBinding()]
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
        
        $computers = Get-CCMComputer -All
        $groups = Get-CCMGroup -All

        $ComputerCollection = [System.Collections.Generic.List[psobject]]::new()
        $GroupCollection = [System.Collections.Generic.List[psobject]]::new()

        foreach ($c in $Computer) {
            $Cresult = $computers | Where-Object { $_.Name -eq "$c" } | Select-Object Name,Id
            $ComputerCollection.Add($Cresult)
        }

        foreach ($g in $Group) {
            $Gresult = $groups | Where-Object { $_.Name -eq "$g" } | Select-Object Name,Id
            $GroupCollection.Add($Gresult)
        }

    }

    process {

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/CreateOrEdit"
            Method      = "post"
            ContentType = "application/json"
            Body        = @{
                Name        = $Name
                Description = $Description
                Groups      = @($GroupCollection | ForEach-Object { [pscustomobject]@{ computerId ="$($_.id)" }})
                Computers   = @($ComputerCollection | ForEach-Object { [pscustomobject]@{ computerId = "$($_.id)"}})
            } | ConvertTo-Json
            WebSession  = $Session
        }
    
        try {
            $response = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
    
        catch {
            throw $_.Exception.Message
        }

        [pscustomobject]@{
            name = $Name
            description = $Description
            groups = $GroupCollection
            computers = $ComputerCollection
        }
    }

}
function Add-CCMGroupMember {
    <#
    .SYNOPSIS
    Adds a member to an existing Group in CCM
    
    .DESCRIPTION
    Add new computers and groups to existing Central Management Groups
    
    .PARAMETER Name
    The group to edit
    
    .PARAMETER Computer
    The computer(s) to add
    
    .PARAMETER Group
    The group(s) to add
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [parameter(ParameterSetName = "Computer")]
        [parameter(ParameterSetName = "Group")]
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
        
        $computers = Get-CCMComputer -All
        $groups = Get-CCMGroup -All
    
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
function Connect-CCMServer {
    <#
    .SYNOPSIS
    Creates a session to a CCM instance
    
    .DESCRIPTION
    Creates a web session cookie used for other cmdlets in the ChocoCCM module
    
    .PARAMETER Hostname
    The hostname and port number of your Central Management installation
    
    .PARAMETER Credential
    The credentials for your Central Management installation. YOu'll be prompted if left blank
    
    .EXAMPLE
    Connect-CCMServer -Hostname localhost:8090

    .EXAMPLE
    $cred = Get-Credential ; Connect-CCMServer -Hostname localhost:8090 -Credential $cred
    
    .NOTES
    
    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0)]
        [String]
        $Hostname,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [switch]
        $UseSSL
    )

        begin{
            $script:Hostname = $Hostname
            $protocol = 'http'
        }
        process {

            if($UseSSL){
                $protocol = 'https'
            }
            $body = @{
                usernameOrEmailAddress = "$($Credential.UserName)"
                password = "$($Credential.GetNetworkCredential().Password)"
            }

            $Result = Invoke-WebRequest -Uri "$($protocol)://$Hostname/Account/Login" -Method POST -ContentType 'application/x-www-form-urlencoded' -Body $body -SessionVariable Session -Erroraction Stop
            
            $Script:Session = $Session
            $Script:Protocol = $protocol

        }
    
}
function Export-CCMDeployment {
    <#
    .SYNOPSIS
    Exports a Deployment to CliXML
    
    .DESCRIPTION
    Adds ability to export a deployment as cli-xml. Useful for backup/source control of deployments

    .PARAMETER Deployment
    The CCM Deployment to Export
    
    .PARAMETER DeploymentStepsOnly
    Only export a deployment's steps
    
    .PARAMETER OutFile
    The xml file to save the deployment as
    
    .PARAMETER AllowClobber
    Allow a file to be overwritten if it already exists
    
    .EXAMPLE
    Export-CCMDeployment -Deployment TestDeployment -OutFile C:\temp\testdeployment.xml

    .EXAMPLE
    Export-CCMDeployment -Deployment UpgradeChrome -OutFile C:\temp\upgradechrome_ccmdeployment.xml -AllowClobber
    
    #>
    [cmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment,

        [Parameter()]
        [Switch]
        $DeploymentStepsOnly,

        [Parameter(Mandatory)]
        [String]
        $OutFile,

        [Parameter()]
        [Switch]
        $AllowClobber
    )

    process {

        $exportParams = if ($AllowClobber) {
            @{
                Force = $true
            } 
        } else {
            @{}
        }
        $DeploymentObject = Get-CCMDeployment -Name $Deployment

        if ($DeploymentStepsOnly) {
            $DeploymentObject.deploymentSteps | Export-Clixml -Depth 10 -Path $OutFile -Force @exportParams
        } else {
            $DeploymentObject | Export-Clixml -Depth 10 -Path $OutFile @exportParams
        }
    }
}
function Export-CCMDeploymentDetail {
    <#
    .SYNOPSIS
    Downloads a deployment report from Central Management
    
    .DESCRIPTION
    Downloads a deployment report from Central Management in PDF or Excel format
    
    .PARAMETER Deployment
    The deployment from which to generate and download a report
    
    .PARAMETER Type
    The type  of report, either PDF or Excel
    
    .PARAMETER OutputFolder
    The path to save the report too
    
    .EXAMPLE
    Export-CCMDeploymentDetail -Deployment 'Complex' -Type PDF -OutputFolder C:\temp\

    .EXAMPLE
    Export-CCMDeploymentDetail -Deployment 'Complex -Type Excel -OutputFolder C:\CCMReports
    
    #>
    [cmdletBinding()]
    param([ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
        

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment,

        [parameter(Mandatory)]
        [ValidateSet('PDF', 'Excel')]
        [string]
        $Type,

        [parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string]
        $OutputFolder
    )
    begin {

        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
    }
    process {

        $irmParams = @{
            Method      = "Get"
            ContentType = "application/json"
            WebSession  = $Session
        }

        switch ($Type) {
            'PDF' {
                $url = "$($protocol)://$hostname/api/services/app/DeploymentPlans/GetDeploymentPlanDetailsToPdf?deploymentPlanId=$deployId"
            }
            'Excel' { $url = "$($protocol)://$hostname/api/services/app/DeploymentPlans/GetDeploymentPlanDetailsToExcel?deploymentPlanId=$deployId" }
        }

        $irmParams.Add('Uri', "$url")

        try {
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop            
            $fileName = $record.result.fileName
            $fileType = $record.result.fileType
            $fileToken = $record.result.fileToken
        }
        catch {
            throw $_.Exception
        }

        $downloadParams = @{
            Uri         = "$($protocol)://$hostname/File/DownloadTempFile?fileType=$fileType&fileToken=$fileToken&fileName=$fileName"
            OutFile     = "$($OutputFolder)\$($fileName)"
            WebSession  = $Session
            Method      = "GET"
            ContentType = $fileType
        }

        try {
            $dl = Invoke-RestMethod @downloadParams -ErrorAction Stop
        }

        catch {
            $_.ErrorDetails
        }

    }
}
function Export-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    Download an outdated Software report from Central Management
    
    .DESCRIPTION
    Download either a PDF or Excel format report of outdated software from Central Management
    
    .PARAMETER Report
    The report to download
    
    .PARAMETER Type
    Specify either PDF or Excel
    
    .PARAMETER OutputFolder
    The path to save the file
    
    .EXAMPLE
    Export-CCMOutdatedSoftwareReport -Report '7/4/2020 6:44:40 PM' -Type PDF -OutputFolder C:\CCMReports
    
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMOutdatedSoftwareReport).creationTime
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Report,
        [parameter(Mandatory)]
        [ValidateSet('PDF', 'Excel')]
        [string]
        $Type,

        [parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string]
        $OutputFolder
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        $reportId = Get-CCMOutdatedSoftwareReport | Where-Object { $_.creationTime -eq "$Report" } | Select -ExpandProperty id

        $irmParams = @{
            Method      = "Get"
            ContentType = "application/json"
            WebSession  = $Session
        }

        switch ($Type) {
            'PDF' { $url = "$($protocol)://$hostname/api/services/app/OutdatedReports/GetOutdatedSoftwareToPdf?reportId=$reportId" }
            'Excel' { $url = "$($protocol)://$hostname/api/services/app/OutdatedReports/GetOutdatedSoftwareToExcel?reportId=$reportId" }
        }

        $irmParams.Add('Uri', "$url")

        try {
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop
            $fileName = $record.result.fileName
            $fileType = $record.result.fileType
            $fileToken = $record.result.fileToken
        }
        catch {
            throw $_.Exception
        }

        $downloadParams = @{
            Uri         = "$($protocol)://$hostname/File/DownloadTempFile?fileType=$fileType&fileToken=$fileToken&fileName=$fileName"
            OutFile     = "$($OutputFolder)\$($fileName)"
            WebSession  = $Session
            Method      = "GET"
            ContentType = $fileType
        }

        try {
            $dl = Invoke-RestMethod @downloadParams -ErrorAction Stop
        }

        catch {
            $_.ErrorDetails
        }

    }
}
Function Get-CCMComputer {
    <#
    .SYNOPSIS
    Returns information about computers in CCM
    
    .DESCRIPTION
    Query for all, or by computer name/id to retrieve information about the system as reported in Central Management
    
    .PARAMETER All
    Returns all computers
    
    .PARAMETER Computer
    Returns the specified computer(s)
    
    .PARAMETER Id
    Returns the information for the computer with the specified id
    
    .EXAMPLE
    Get-CCMComputer -All

    .EXAMPLE
    Get-CCMComputer -Computer web1

    .EXAMPLE
    Get-CCMComputer -Id 13
    
    .NOTES
    
    #>
    [cmdletBinding(DefaultParameterSetName = "All")]
    Param(
            

        [Parameter(Mandatory, ParameterSetName = "All")]
        [Switch]
        $All,

        [Parameter(Mandatory, ParameterSetName = "Computer")]
        [string]
        $Computer,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id

    )

    begin {
        If (-not $Session) {

            throw "Unauthenticated! Please run Connect-CCMServer first"

        }

    }

    process {

        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Computers/GetAll" -WebSession $Session
        } 
        
        Switch ($PSCmdlet.ParameterSetName) {
            "All" {

                $records.result

            }

            "Computer" {

                $data.result.items | Where-Object { $_.name -match "$Computer" }

            }

            "Id" {

                $records = Invoke-RestMethod-Uri "$($protocol)://$Hostname/api/services/app/Computers/GetComputerForEdit?Id=$Id" -WebSession $Session
                $records

            }

        }
       
    }
    
}
function Get-CCMDeployment {
    <#
    .SYNOPSIS
    Return information about a CCM Deployment
    
    .DESCRIPTION
    Returns detailed information about Central Management Deployment Plans
    
    .PARAMETER All
    Returns all Deployment Plans
    
    .PARAMETER Name
    Returns the named Deployment Plan
    
    .PARAMETER Id
    Returns the Deployment Plan with the give Id
    
    .EXAMPLE
    Get-CCMDeployment -All
    
    .EXAMPLE
    Get-CCMDeployment -Name Bob

    .EXAMPLE
    Get-CCMDeployment -Id 583
    #>
    [cmdletBinding(DefaultParameterSetName="All")]
    param(
        [parameter(ParameterSetName="All",Mandatory)]
        [switch]
        $All,

        [parameter(ParameterSetName="Name",Mandatory)]
        [string]
        $Name,

        [Parameter(ParameterSetName="Id",Mandatory)]
        [string]
        $Id
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetAll" -WebSession $Session
        } 

        switch($PSCmdlet.ParameterSetName){
            'All' {
                $records.result
            }

            'Name' {
                
                $queryId = $records.result | Where-Object { $_.Name -eq "$Name"} | Select-Object -ExpandProperty Id
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetDeploymentPlanForView?Id=$queryId" -WebSession $Session
                $records.result.deploymentPlan

            }

            'Id' {
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/DeploymentPlans/GetDeploymentPlanForView?Id=$id" -WebSession $Session
                $records.result.deploymentPlan
            }
        }
    }
}
function Get-CCMGroup {
    <#
    .SYNOPSIS
    Returns group information for your CCM installation
    
    .DESCRIPTION
    Returns information about the groups created in your CCM Installation
    
    .PARAMETER All
    Returns all groups
    
    .PARAMETER Group
    Returns group with the provided name
    
    .PARAMETER Id
    Returns group withe the provided id
    
    .EXAMPLE
    Get-CCMGroup -All

    .EXAMPLE
    Get-CCMGroup -Id 1

    .EXAMPLE
    Get-CCMGroup -Group 'Web Servers'
    
    #>
    [cmdletBinding(DefaultParameterSetName = "All")]
    param(
        [parameter(Mandatory, ParameterSetName = "All")]
        [switch]
        $All,

        [parameter(Mandatory, ParameterSetName = "Group")]
        [string[]]
        $Group,

        [parameter(Mandatory, ParameterSetName = "Id")]
        [String[]]
        $Id
    )

    begin {
        If (-not $Session) {

            throw "Unauthenticated! Please run Connect-CCMServer first"

        }

    }
    process {
        if (-not $Id) {
            $records = Invoke-RestMethod -Method Get -Uri "$($protocol)://$hostname/api/services/app/Groups/GetAll" -WebSession $Session
            #$records = Invoke-We -Uri http://$Hostname/api/services/app/Groups/GetAll -WebSession $Session -UseBasicParsing
        } 
        
        Switch ($PSCmdlet.ParameterSetName) {
            "All" {

                $records.result

            }

            "Group" {

                $records.result | Where-Object { $_.name -in $Group }

            }

            "Id" {
                $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Groups/GetGroupForEdit?Id=$Id" -WebSession $Session
                $records.result
            }

        }

    }
}
function Get-CCMGroupMember {
    <#
    .SYNOPSIS
    Returns information about a CCM group's members
    
    .DESCRIPTION
    Return detailed group information from Chocolatey Central Management
    
    .PARAMETER Group
    The Group to query
    
    .EXAMPLE
    Get-CCMGroupMember -Group "WebServers"
    
    #>
    [cmdletBinding()]
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
        $Group
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {
        $Id = (Get-CCMGroup -Group $Group).Id
        $irmParams = @{
            Uri         = "$($protocol)://localhost:8090/api/services/app/Groups/GetGroupForEdit?id=$Id"
            Method      = "GET"
            ContentType = "application/json"
            WebSession  = $Session
        }

        try {
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        $cCollection = [System.Collections.Generic.List[psobject]]::new()
        $gCollection = [System.Collections.Generic.List[psobject]]::new()

        $record.result.computers | ForEach-Object {
            $cCollection.Add($_)
        }

        $record.result.groups | ForEach-Object {
            $gCollection.Add($_)
        }
       
        [pscustomobject]@{
            Name        = $record.result.Name
            Description = $record.result.Description
            Groups      = @($gCollection)
            Computers   = @($cCollection)
            CanDeploy   = $record.result.isEligibleForDeployments
        } 

        
    }
}
function Get-CCMOutdatedPackageMember {
    [cmdletBinding()]
    param(
        [parameter()]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMSoftware -All | Where-Object { $_.isOutdated -eq $true}).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Software,

        [parameter()]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMSoftware -All | Where-Object { $_.isOutdated -eq $true}).packageId
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Package
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        if($Software){
            $id = Get-CCMSoftware -Software $Software | Select-Object -ExpandProperty id

        }

        if($Package){
            $id = Get-CCMSoftware -Package $Package | Select-Object -ExpandProperty id

        }
        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$id&skipCount=0&maxResultCount=100"
            Method = "GET"
            ContentType = "application/json"
            WebSession = $Session
        }

        try {
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop
        } catch {
            $_.Exception.Message
        }

        $record.result.items| Foreach-Object {
            [pscustomobject]@{
                softwareId = $_.softwareId
                software = $_.software.name
                packageName = $_.software.packageId
                packageVersion = $_.software.packageVersion
                name = $_.computer.name
                friendlyName = $_.computer.friendlyName
                ipaddress = $_.computer.ipaddress
                fqdn = $_.computer.fqdn
                computerid = $_.computer.id
    
            }
        }

    }
}
function Get-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    List all Outdated Software Reports generated in Central Management
    
    .DESCRIPTION
    List all Outdated Software Reports generated in Central Management
    
    .EXAMPLE
    Get-CCMOutdatedSoftwareReport
    
    #>
    [cmdletBinding()]
    param()

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {
        $irmParams =  @{
            Uri = "$($protocol)://$hostname/api/services/app/Reports/GetAllPaged?reportTypeFilter=1"
            Method = "Get"
            ContentType = "application/json"
            WebSession = $Session
        }

         try {
             $response = Invoke-RestMethod @irmParams
         }
         catch{
             throw $_.Exception.Message
         }

         $response.result.items | % {
            [pscustomobject]@{
                reportType = $_.report.reportType -as [String]
                creationTime = $_.report.creationTime -as [String]
                id = $_.report.id -as [string]
            }


         }
         
    }
}
function Get-CCMOutdatedSoftwareReportDetail {
    <#
    .SYNOPSIS
    View detailed information about an Outdated Software Report
    
    .DESCRIPTION
    Return report details from an Outdated Software Report in Central Management
    
    .PARAMETER Report
    The report to query
    
    .EXAMPLE
    Get-CCMOutdatedSoftwareReportDetail -Report '7/4/2020 6:44:40 PM'
    
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMOutdatedSoftwareReport).creationTime
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Report
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {
        $reportId = Get-CCMOutdatedSoftwareReport | Where-Object {$_.creationTime -eq "$Report"} | Select -ExpandProperty id

        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/OutdatedReports/GetAllByReportId?reportId=$reportId&sorting=outdatedReport.packageDisplayText%20asc&skipCount=0&maxResultCount=200"
            Method = "Get"
            ContentType = "application/json"
            WebSession = $Session
        }

        try{
            $response = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        $response.result.items.outdatedReport

    }
}
function Get-CCMRole {
    [cmdletBinding(DefaultParameterSetName="All")]
    param(
        [parameter(ParameterSetName="All")]
        [switch]
        $All,

        [parameter(ParameterSetName="Name")]
        [string]
        $Name

    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/Role/GetRoles?permission="
            Method = "GET"
            ContentType = "application/json"
            WebSession = $Session
        }

        try{
            $response = Invoke-RestMethod @irmParams -ErrorAction Stop
        } catch {
            throw $_.Exception.Message
        }

        switch($PSCmdlet.ParameterSetName){
            'All' {

                $response.result.items
            }

            'Name' {
                $response.result.items | Where-Object { $_.name -eq $Name }
            }
        }
    }
}
Function Get-CCMSoftware {
    <#
    .SYNOPSIS
    Returns information about software tracked inside of CCM
    
    .DESCRIPTION
    Return information about each piece of software managed across all of your estate inside Central Management
    
    .PARAMETER All
    Return a list of all currently tracked software
    
    .PARAMETER Software
    Return information about a specific piece of software by friendly name

    .PARAMETER Package
    Return information about a specific package
    
    .PARAMETER Id
    Return information about a specific piece of software by id
    
    .EXAMPLE
    Get-CCMSoftware -All

    .EXAMPLE
    Get-CCMSoftware -Software 'VLC Media Player'

    .EXAMPLE
    Get-CCMSoftware -Package vlc

    .EXAMPLE
    Get-CCMSoftware -Id 37
    
    .NOTES
    #>
    [cmdletBinding(DefaultParameterSetName = "All")]
    Param(
            

        [Parameter(Mandatory, ParameterSetName = "All")]
        [Switch]
        $All,

        [Parameter(Mandatory, ParameterSetName = "Software")]
        [string]
        $Software,
        
        [Parameter(Mandatory,ParameterSetName = "Package")]
        [string]
        $Package,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id

    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        if (-not $Id) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Software/GetAll" -WebSession $Session -UseBasicParsing
        } 
        
        Switch ($PSCmdlet.ParameterSetName) {
            "All" {
                $records.result.items
            }

            "Software" {
                $softwareId = $records.result.items | Where-Object {$_.name -eq "$Software"} | Select-Object -ExpandProperty Id

                $irmParams = @{
                    WebSession = $Session
                    Uri = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$softwareID&skipCount=0&maxResultCount=500"
                }
                
                $records = Invoke-RestMethod @irmParams
                $records.result.items

            }

            "Package" {
                $packageId = $records.result.items | Where-Object {$_.packageId -eq "$Package"} | Select-Object -ExpandProperty id

                $irmParams = @{
                    WebSession = $Session
                    Uri = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$packageID&skipCount=0&maxResultCount=500"
                }
                
                $records = Invoke-RestMethod @irmParams
                $records.result.items
            }

            "Id" {

                $irmParams = @{
                    WebSession = $Session
                    Uri = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$Id&skipCount=0&maxResultCount=500"
                }
                $records = Invoke-RestMethod @irmParams
                $records.result
            }

        }
       
    }
}
function Get-DeploymentResult {
    [cmdletBinding()]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id

    }

    process {

        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/GetAllPagedByDeploymentPlanId?resultFilter=Success%2CFailed%2CUnreachable%2CInconclusive%2CReady%2CActive%2CCancelled%2CUnknown%2CDraft&deploymentPlanId=$deployId&sorting=planOrder%20asc&skipCount=0&maxResultCount=10"
            Method = "GET"
            ContentType = "application/json"
            WebSession = $Session
        }

        try {
            $records = Invoke-RestMethod @irmParams -ErrorAction Stop
            $records.result.items
        }
        catch{
            throw $_.Exception.Message
        }
    }
}
function Import-PDQDeployPackage {
    <#
    .SYNOPSIS
    Imports a PDQ Deploy package as a Central Management Deployment
    
    .DESCRIPTION
    Imports a PDQ Deploy package as a Central Management Deployment
    
    .PARAMETER PdqXml
    The pdq xml file to import
    
    .EXAMPLE
    Import-PDQDeployPackage
    
    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [String]
        $PdqXml
    )

    process {
        [xml]$xmlData = Get-Content $PdqXml

        $deploymentName = $xmlData.SelectNodes("//*[Name]").Name
        $deploymentName = "PDQ Import: $deploymentName"
        
        Write-Verbose "Adding deployment with name: $deploymentName"
        New-CCMDeployment -Name $deploymentName

        $deploymentSteps = $xmldata.SelectNodes("//*[Steps]").Steps

        $deploymentSteps = $deploymentSteps | ForEach-Object {

            if ($_.InstallStep) {
        
                $_.InstallStep | Foreach-Object { 
                    [pscustomobject]@{
                        SuccessCodes  = @($_.SuccessCodes)
                        FailureAction = $_.ErrorMode
                        Type          = switch ($_.Typename) {
                            'Install' { "Basic" }
                        }
                        Package       = $deploymentName
                        Title         = if ($_.title) { $_.title } else { "Install $deploymentName" }
                    }
                }
            }
        }

        $ccmSteps = @{
            Type           = $deploymentSteps.Type
            ValidExitCodes = $deploymentSteps.SuccessCodes
        }

        if ($deploymentSteps.FailureAction -eq 'StopdeploymentFail') {
            $ccmSteps.Add('FailOnError', $true)
        }
        else {
            $ccmSteps.Add('FailOnError', $false)
        }

        if ($deploymentSteps.Type -eq 'Basic') {
            $ccmSteps.Add('ChocoCommand', 'upgrade')
            $ccmSteps.add('Package', '7-zip')
        }

        Write-Verbose "Adding steps from imported package to Deployment"
        New-CCMDeploymentStep -Deployment $deploymentName -Name $deploymentSteps.Title @ccmSteps

    }
    
    end {
        Write-Warning "No targets will be defined for this deployment"
    }
}
function Invoke-ArchiveCCMDeployment {
    <#
    .SYNOPSIS
    Archive a CCM Deployment
    
    .DESCRIPTION
    Moves a deployment in Central Management to the archive
    
    .PARAMETER Deployment
    The deployment to archive
    
    .EXAMPLE
    Invoke-ArchiveCCMDeployment -Deployment 'Upgrade VLC'

    .EXAMPLE
    Archive-CCMDeployment -Deployment 'Upgrade VLC'
    
    #>
    [Alias('Archive-CCMDeployment')]
    [cmdletBinding(ConfirmImpact = "high", SupportsShouldProcess)]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment
    )
    begin {

        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
    }
    process {
    
        if ($PSCmdlet.ShouldProcess("$Deployment", "ARCHIVE")) {
            $irmParams = @{
                Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Archive"
                Method      = "POST"
                ContentType = "application/json"
                Body        = @{ id = "$deployId" } | ConvertTo-Json
                Websession  = $Session
            }

            try {
                $null = Invoke-RestMethod @irmParams -ErrorAction Stop
            }
            catch {
                throw $_.Exception.Message
            }
        }
    }
}
function Move-CCMDeploymentToReady {
<#
    .SYNOPSIS
    Moves a  deployment to Ready state
    
    .DESCRIPTION
    Moves a Deployment to the Ready state so it can start
    
    .PARAMETER Deployment
    The deployment  to  move
    
    .EXAMPLE
    Move-CCMDeploymentToReady -Deployment 'Upgrade Outdated VLC'

    .EXAMPLE
    Move-CCMDeploymenttoReady -Deployment 'Complex Deployment'
    
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = Get-CCMDeployment -All
                

                If ($WordToComplete) {
                    $r.name.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r.name
                }
            }
        )]
        [string]
        $Deployment
    )

    Begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        
        $id = (Get-CCMDeployment -Name $Deployment).id

    }
    process {

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/MoveToReady"
            Method      = "POST"
            ContentType = "application/json"
            Body        = @{ id = "$id" } | ConvertTo-Json
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
function New-CCMDeployment {
    <#
    .SYNOPSIS
    Create a new CCM Deployment Plan
    
    .DESCRIPTION
    Creates a new CCM Deployment. This is just a shell. You'll need to add steps with New-CCMDeploymentStep.
    
    .PARAMETER Name
    The name for the deployment
    
    .EXAMPLE
    New-CCMDeployment -Name 'This is awesome'
    
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]
        $Name
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/DeploymentPlans/CreateOrEdit"
            Method = "POST"
            ContentType = "application/json"
            Body = @{ Name = "$Name"} | ConvertTo-Json
            WebSession = $Session
        }

        try{
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop
        }

        catch {
            throw $_.Exception.Message
        }

        [pscustomobject]@{
            name = $Name
            id = $record.result.id
        }
    }
}
function New-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Adds a Deployment Step to a Deployment Plan
    
    .DESCRIPTION
    Adds both Basic and Advanced steps to a Deployment Plan
    
    .PARAMETER Deployment
    The Deployment where the step will be added
    
    .PARAMETER Name
    The Name of the step
    
    .PARAMETER TargetGroup
    The group(s) the step will target
    
    .PARAMETER ExecutionTimeoutSeconds
    How long to wait for the step to timeout. Defaults to 14400 (4 hours)
    
    .PARAMETER FailOnError
    Fail the step if there is an error. Defaults to True
    
    .PARAMETER RequireSuccessOnAllComputers
    Ensure all computers are successful before moving to the next step.
    
    .PARAMETER ValidExitCodes
    Valid exit codes your script can emit. Default values are: '0','1605','1614','1641','3010'
    
    .PARAMETER Type
    Either a Basic or Advanced Step
    
    .PARAMETER ChocoCommand
    Select from Install,Upgrade, or Uninstall. Used with a Simple step type.

    .PARAMETER PackageName
    The chocolatey package to use with a simple step.

    .PARAMETER Script
    A scriptblock your Advanced step will use

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup WebServers -Type Basic -ChocoCommand upgrade -PackageName firefox

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script { $process = Get-Process
>> 
>> Foreach($p in $process){
>> Write-Host $p.PID
>> }
>> 
>> Write-Host "end"
>> 
>> }

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script {(Get-Content C:\script.txt)}
    
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment,

        [parameter(Mandatory)]
        [string]
        $Name,

        [parameter()]
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
        [string[]]
        $TargetGroup = @(),

        [parameter()]
        [string]
        $ExecutionTimeoutSeconds = '14400',

        [parameter()]
        [switch]
        $FailOnError = $true,

        [parameter()]
        [switch]
        $RequireSuccessOnAllComputers = $false,

        [parameter()]
        [string[]]
        $ValidExitCodes = @('0','1605','1614','1641','3010'),

        [parameter(Mandatory,ParameterSetName="StepType")]
        [parameter(Mandatory,ParameterSetName="Basic")]
        [parameter(Mandatory,ParameterSetName="Advanced")]
        [ValidateSet('Basic','Advanced')]
        [string]
        $Type,

        [parameter(Mandatory,ParameterSetName="Basic")]
        [ValidateSet('Install','Upgrade','Uninstall')]
        [string]
        $ChocoCommand,

        [parameter(Mandatory,ParameterSetName="Basic")]
        [string]
        $PackageName,

        [parameter(Mandatory,ParameterSetName="Advanced")]
        [scriptblock]
        $Script
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        switch($PSCmdlet.ParameterSetName){
            'Basic' {
                $Body = @{
                    Name = "$Name"
                    DeploymentPlanId = "$(Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id)"
                    DeploymentStepGroups = if($TargetGroup.Count -gt 0){
                        @(Get-CCMGroup -Group $TargetGroup | Select-Object Name,Id | ForEach-Object { [pscustomobject]@{groupId = $_.id ; groupName = $_.name}})
                    } else {
                        @()
                    }
                    ExecutionTimeoutInSeconds = "$ExecutionTimeoutSeconds"
                    RequireSuccessOnAllComputers = "$RequireSuccessOnAllComputers"
                    failOnError = "$FailOnError"
                    validExitCodes = "$($validExitCodes -join ',')"
                    script = "$($ChocoCommand)|$($PackageName)"
                    
                } | ConvertTo-Json

            }

            'Advanced' {
                $Body = @{
                    Name = "$Name"
                    DeploymentPlanId = "$(Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id)"
                    DeploymentStepGroups = @(Get-CCMGroup -Group $TargetGroup | Select-Object Name,Id | ForEach-Object { [pscustomobject]@{groupId = $_.id ; groupName = $_.name}})
                    ExecutionTimeoutInSeconds = "$ExecutionTimeoutSeconds"
                    RequireSuccessOnAllComputers = "$RequireSuccessOnAllComputers"
                    failOnError = "$FailOnError"
                    validExitCodes = "$($validExitCodes -join ',')"
                    script = "$($Script.ToString())"
                } | ConvertTo-Json
                
            }
        }

        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/CreateOrEdit"
            Method = "POST"
            ContentType = "application/json"
            WebSession = $Session
            Body = $Body
            
        }

        try{
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch{
            throw $_.Exception.Message
        }

    }
}
function New-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    Create a new Outdated Software Report in Central Management
    
    .DESCRIPTION
    Create a new Outdated Software Report in Central Management
    
    .EXAMPLE
    New-CCMOutdatedSoftwareReport
    
    .NOTES
    Creates a new report named with a creation date timestamp in UTC format
    #>
    [cmdletBinding()]
    param()

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {
        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/OutdatedReports/Create"
            Method = "POST"
            ContentType = 'application/json'
            WebSession = $Session
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
function Remove-CCMDeployment {
    <#
    .SYNOPSIS
    Removes a deployment plan
    
    .DESCRIPTION
    Removes the Deployment Plan selected from a Central Management installation
    
    .PARAMETER Deployment
    The Deployment to  delete
    
    .EXAMPLE
    Remove-CCMDeployment -Name 'Super Complex Deployment'

    .EXAMPLE
    Remove-CCMDeployment -Name 'Deployment Alpha' -Confirm:$false
    
    #>
    [cmdletBinding(ConfirmImpact = "High", SupportsShouldProcess)]
    param(
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string[]]
        $Deployment
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = [System.Collections.Generic.List[string]]::new() 
        
        $Deployment | % { $deployId.Add($(Get-CCMDeployment -Name $_ | Select-Object -ExpandProperty Id)) }
    }
    process {
        
        $deployId | ForEach-Object {
            if ($PSCmdlet.ShouldProcess("$Deployment", "DELETE")) {
                $irmParams = @{
                    Uri = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Delete?Id=$($_)"
                    Method = "DELETE"
                    ContentType = "application/json"
                }
    
                Invoke-RestMethod @irmParams
            }

        }
        
    }
}
function Remove-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Removes a deployment plan
    
    .DESCRIPTION
    Removes the Deployment Plan selected from a Central Management installation
    
    .PARAMETER Deployment
    The Deployment to  remove a step from

    .PARAMETER Step
    The Step to remove

    .EXAMPLE
    Remove-CCMDeploymentStep -Name 'Super Complex Deployment' -Step 'Kill web services'

    .EXAMPLE
    Remove-CCMDeploymentStep -Name 'Deployment Alpha' -Step 'Copy Files' -Confirm:$false
    
    #>
    [cmdletBinding(ConfirmImpact = "High", SupportsShouldProcess)]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All)
                

                If ($WordToComplete) {
                    $r.Name.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r.Name
                }
            }
        )]
        [string]
        $Deployment,

        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $d = (Get-CCMDeployment -Name $($FakeBoundParams.Deployment)).id
                $idSteps = (Get-CCMDeployment -Id $d).deploymentSteps.Name

                If ($WordToComplete) {
                    $idSteps.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $idSteps
                }
            }
        )]
        [string]
        $Step

    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
        $deploymentSteps = Get-CCMDeployment -Id $deployId | Select-Object deploymentSteps
        $stepId = $deploymentSteps.deploymentSteps | Where-Object { $_.Name -eq "$Step"} | Select -ExpandProperty id

    }
    process {
    
        if ($PSCmdlet.ShouldProcess("$Step", "DELETE")) {
            $irmParams = @{
                Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/Delete?Id=$stepId"
                Method = "DELETE"
                ContentType = "application/json"
                WebSession = $Session
            }

            $null = Invoke-RestMethod @irmParams
        }
    }
}
function Remove-CCMGroup {
    <#
    .SYNOPSIS
    Removes a CCM group
    
    .DESCRIPTION
    Removes a group from Chocolatey Central Management
    
    .PARAMETER Group
    The group(s) to delete
    
    .EXAMPLE
    Remove-CCMGroup -Group WebServers

    .EXAMPLE
    Remove-CCMGroup -Group WebServer,TestAppDeployment

    .EXAMPLE
    Remove-CCMGroup -Group PilotPool -Confirm:$false

    #>
    [cmdletBinding(ConfirmImpact = "High", SupportsShouldProcess)]
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
        [string[]]
        $Group
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        $Group | ForEach-Object {

            $id = Get-CCMGroup -Group $_ | Select-Object -ExpandProperty Id

            $irmParams = @{
                Uri         = "$($protocol)://$hostname/api/services/app/Groups/Delete?id=$id"
                Method      = "DELETE"
                ContentType = "application/json"
                WebSession  = $Session
            }

            if ($PSCmdlet.ShouldProcess($Group, "DELETE")) {
                
                Write-Verbose -Message "Removing group: $($_) with Id: $($id)"

                try {
                    $null = Invoke-RestMethod @irmParams -ErrorAction Stop
                }

                catch {
                    throw $_.Exception.Message
                }

            }
        }
    }
}
function Remove-CCMGroupMember {
    [cmdletBinding(ConfirmImpact="High",SupportsShouldProcess)]
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
function Remove-CCMStaleDeployment {
    <#
    .SYNOPSIS
    Removes stale CCM Deployments
    
    .DESCRIPTION
    Remove stale deployments from CCM based on their age and run status.
    
    .PARAMETER Age
    The age in days to prune
    
    .EXAMPLE
    Remove-StaleCCMDeployment -Age 30   
        
    #>
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [string]
        $Age
    )

    begin {

    }

    process {
        <#
            Bad States:
            Unknown = 0
            Pending = 2
            Failed = 8
        #>
        $badStates = @(0,2,8)
        if ($PSCmdlet.ShouldProcess("$Deployment", "DELETE")) {
            Get-CCMDeployment -All | Where-Object { $_.CreationDate -ge (Get-Date).AddDays(-$Age) -and $null -eq $_.StartDateTimeUtc -and $_.Result -in $badStates} | Remove-CCMDeployment
        }
    }

}
function Set-CCMDeploymentStep {
    [cmdletBinding(DefaultParameterSetName="Dumby")]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If($WordToComplete){
                    $r.Where{$_ -match "^$WordToComplete"}
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment,

        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $d = (Get-CCMDeployment -Name $($FakeBoundParams.Deployment)).id
                $idSteps = (Get-CCMDeployment -Id $d).deploymentSteps.Name

                If ($WordToComplete) {
                    $idSteps.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $idSteps
                }
            }
        )]
        [string]
        $Step,

        [parameter()]
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
        [string[]]
        $TargetGroup,

        [parameter()]
        [string]
        $ExecutionTimeoutSeconds,

        [parameter()]
        [switch]
        $FailOnError,

        [parameter()]
        [switch]
        $RequireSuccessOnAllComputers,

        [parameter()]
        [string[]]
        $ValidExitCodes,

        [parameter(Mandatory,ParameterSetName="Basic")]
        [ValidateSet('Install','Upgrade','Uninstall')]
        [string]
        $ChocoCommand,

        [parameter(Mandatory,ParameterSetName="Basic")]
        [string]
        $PackageName,

        [parameter(Mandatory,ParameterSetName="Advanced")]
        [scriptblock]
        $Script
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
        $deploymentSteps = Get-CCMDeployment -Id $deployId | Select-Object deploymentSteps
        $stepId = $deploymentSteps.deploymentSteps | Where-Object { $_.Name -eq "$Step"} | Select -ExpandProperty id



        $existingstepsParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/DeploymentSteps/GetDeploymentStepForView?Id=$stepId"
            Method = "Get"
            ContentType = "application/json"
            WebSession = $Session
        }
        
        try{
            $existingsteps = Invoke-RestMethod @existingstepsParams -Erroraction Stop
        } catch {
            throw $_.Exception.Message
        }

        $existingsteps = $existingsteps.result.deploymentStep
        $existingsteps

    }

    process {

        #So many if statements, so little time
        foreach($param in $PSBoundParameters){

            $param.Name
            $param.Value
            #$existingsteps.$($param.Key) = $param.Value
        }

        #$existingsteps
    }



}
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
function Set-CCMNotificationStatus {
    <#
    .SYNOPSIS
    Turn notifications on or off in CCM
    
    .DESCRIPTION
    Manage your notification settings in Central Management. Currently only supports On, or Off
    
    .PARAMETER Enable
    Enables notifications
    
    .PARAMETER Disable
    Disables notifications
    
    .EXAMPLE
    Set-CCMNotificationStatus -Enable

    .EXAMPLE
    Set-CCMNotificationStatus -Disable

    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory,ParameterSetName="Enabled")]
        [switch]
        $Enable,

        [parameter(Mandatory,ParameterSetName="Disabled")]
        [switch]
        $Disable
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {

        switch($PSCmdlet.ParameterSetName){
            'Enabled' { $status = $true}

            'Disabled'{ $status = $false}
        }

        $irmParams = @{
            Uri = "$($protocol)://$hostname/api/services/app/Notification/UpdateNotificationSettings"
            Method = "PUT"
            ContentType = "application/json"
            WebSession = $Session
            Body = @{
                receiveNotifications = $status
                notifications = @(@{
                    name = "App.NewUserRegistered"
                    isSubscribed = $true
                })
            } | ConvertTo-Json
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
function Start-CCMDeployment {
    <#
    .SYNOPSIS
    Starts a deployment
    
    .DESCRIPTION
    Starts the specified deployment in Central  Management
    
    .PARAMETER Deployment
    The deployment  to  start
    
    .EXAMPLE
    Start-CCMDeployment -Deployment 'Upgrade Outdated VLC'

    .EXAMPLE
    Start-CCMDeployment -Deployment 'Complex Deployment'
    
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = Get-CCMDeployment -All
                

                If ($WordToComplete) {
                    $r.name.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r.name
                }
            }
        )]
        [string]
        $Deployment
    )
    
    Begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $id = (Get-CCMDeployment -Name $Deployment).id

    }
    process {

        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Start"
            Method      = "POST"
            ContentType = "application/json"
            Body        = @{ id = "$id" } | ConvertTo-Json
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
function Stop-CCMDeployment {
    <#
    .SYNOPSIS
    Stops a running CCM Deployment
    
    .DESCRIPTION
    Stops a deployment current running in Central Management
    
    .PARAMETER Deployment
    The deployment to Stop
    
    .EXAMPLE
    Stop-CCMDeployment -Deployment 'Upgrade VLC'
    
    #>
    [cmdletBinding(ConfirmImpact = "high", SupportsShouldProcess)]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Deployment
    )
    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
    }
    process {
    
        if ($PSCmdlet.ShouldProcess("$Deployment", "CANCEL")) {
            $irmParams = @{
                Uri         = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Cancel"
                Method      = "POST"
                ContentType = "application/json"
                Body        = @{ id = "$deployId" } | ConvertTo-Json
                Websession  = $Session
            }

            try {
                $null = Invoke-RestMethod @irmParams -ErrorAction Stop
            }
            catch {
                throw $_.Exception.Message
            }
        }
    }
}
