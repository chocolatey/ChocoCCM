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
    [cmdletBinding(ConfirmImpact = "High", SupportsShouldProcess,HelpUri="https://chocolatey.org/docs/remove-ccmgroup")]
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