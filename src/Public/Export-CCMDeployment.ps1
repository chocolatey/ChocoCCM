function Export-CCMDeployment {
    <#
    .SYNOPSIS
    Exports a Deployment to a CliXML file
    
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