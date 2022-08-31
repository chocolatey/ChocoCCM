Describe "Module Import Checks" {

    BeforeAll {
        $module = (Get-ChildItem "$($env:BuildRepositoryLocalPath)" -Recurse -Filter *.psd1).FullName[1]
    }

    It "The psd1 should be found" {
        $module | Should -Not -BeNullOrEmpty
    }

    It "Module should import without erros" {
        { Import-Module "$module" } | Should -Not -Throw
    }

    It "Should return all public functions" {
        { Get-Command -Module ChocoCCM } | Should -Not -Throw
    }
}

#TODO: Lots of mocks for actual function tests
