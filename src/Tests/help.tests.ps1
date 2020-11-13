
#Blocked until Docs PR is merged

<#

$module = (Get-ChildItem "$($env:BuildRepositoryLocalPath)" -Recurse -Filter *.psd1).FullName[1]

Import-Module $module -Force

$commands = Get-Command -Module ChocoCCM

Describe "Functions have valid help" {
   
    foreach ($Command in $Commands) {
        It "$($Command.Name): HelpUri in CmdletBinding() resolves correctly" {
            $request = [System.Net.WebRequest]::Create("$($Command.HelpUri)")
            $request.StatusCode | Should -Be 'OK'
        }
    }

}
#>

}

