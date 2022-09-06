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

    BeforeAll {
        $client = [System.Net.Http.HttpClient]::new()
    }

    It "<Name>: HelpUri for command is valid" -TestCases $commands {
        param($Name, $HelpUri, $CommandInfo)

        $HelpUri | Should -Not -BeNullOrEmpty
        $response = $client.GetAsync($HelpUri).GetAwaiter().GetResult()
        $response.StatusCode | Should -Be 'OK'
    }

    AfterAll {
        $client.Dispose()
    }
}
