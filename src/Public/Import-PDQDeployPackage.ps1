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
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/importpdqdeploypackage")]
    param(
        [Parameter(Mandatory)]
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
                $_.InstallStep | ForEach-Object {
                    [pscustomobject]@{
                        SuccessCodes  = @($_.SuccessCodes)
                        FailureAction = $_.ErrorMode
                        Type          = switch ($_.Typename) {
                            'Install' {
                                "Basic"
                            }
                        }
                        Package       = $deploymentName
                        Title         = if ($_.title) {
                            $_.title
                        }
                        else {
                            "Install $deploymentName"
                        }
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
