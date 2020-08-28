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
