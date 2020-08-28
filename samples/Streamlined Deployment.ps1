function New-CCMUpgradeOutdatedPackageDeployment {
    [cmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]
        $DeploymentName,

        [parameter(Mandatory)]
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

    process {
    $target = Get-CCMOutdatedPackageMember -Package $Package
    Add-CCMGroup -Name "Upgrade $($target.packageName)" -Description "Computers needing to Upgrade $($target.software)" -Computer $target.name
    
    New-CCMDeployment -Name "Upgrade Notepad++"

$deploymentStepArgs = @{
    Deployment ='Upgrade Notepad++' 
    Name ='Upgrade package to vLatest' 
    TargetGroup= 'Upgrade Notepad++' 
    Type ="Basic"
    ChocoCommand= "Upgrade" 
    PackageName= "$($software.packageId)"
}

New-CCMDeploymentStep @deploymentStepArgs
Move-CCMDeploymentToReady -Deployment 'Upgrade Notepad++'
Start-CCMDeployment -Deployment "Upgrade Notepad++"
    }
}