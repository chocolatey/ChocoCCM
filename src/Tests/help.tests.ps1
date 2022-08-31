$module = (Get-ChildItem "$PSScriptRoot\.." -Recurse -Filter *.psd1)[0].FullName

Import-Module $module -Force

$commands = Get-Command -Module ChocoCCM | ForEach-Object {
    @{
        'Name'        = $_.Name
        'HelpUri'     = $_.HelpUri
        'CommandInfo' = $_
    }
}

Describe "All commands have valid help" {

    It "<Name>: HelpUri for command is valid" -TestCases $commands {
        param($Name, $HelpUri, $CommandInfo)

        $HelpUri | Should -Not -BeNullOrEmpty
        $request = [System.Net.WebRequest]::Create($HelpUri)
        $request.GetResponse().StatusCode | Should -Be 'OK'
    }
}
