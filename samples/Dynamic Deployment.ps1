Connect-CCMServer -Hostname localhost:8090 -Credential $cred

$software = Get-CCMOutdatedSoftwareReportDetail -Report '7/5/2020 3:43:23 PM' | ? {$_.packageId -eq 'notepadplusplus.install'}
Add-CCMGroup -Name "Upgrade Notepad++" -Description "Group For Upgrading Notepad++ Via the api" -Computer $software.computerName
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