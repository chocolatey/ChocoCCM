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