Describe "Module Import Checks" {

    BeforeAll {
        $module = (Get-ChildItem "$PSScriptRoot\.." -Recurse -Filter *.psd1)[0].FullName
    }

    It "The psd1 should be found" {
        $module | Should -Not -BeNullOrEmpty
    }

    It "Module should import without errors" {
        { Import-Module $module } | Should -Not -Throw
    }

    It "Should return all public functions" {
        { Get-Command -Module ChocoCCM } | Should -Not -Throw
    }
}
