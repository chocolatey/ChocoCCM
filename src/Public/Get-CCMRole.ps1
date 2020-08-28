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