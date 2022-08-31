./build.ps1 -Build

Import-Module ./Output/ChocoCCM/ChocoCCM.psd1 -Force

$username = 'ccmadmin'
$passworkd = 'choco' | ConvertTo-SecureString -AsPlainText -Force

$cred = [System.Management.Automation.PSCredential]::new($username, $passworkd)
Connect-CCMServer -Hostname localhost:8090 -Credential $cred
