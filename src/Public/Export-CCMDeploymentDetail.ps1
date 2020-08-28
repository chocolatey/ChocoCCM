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