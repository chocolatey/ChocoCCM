
BeforeAll {
    $root = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
Describe "Module Importability" {

    It "Module should import without erros" {
        Import-Module "$($root)\Output\ChocoCCM\ChocoCCM.psd1" | Should -Not -Throw
    }

    It "Should return all public functions" {
        Get-Command -Module ChocoCCM | Should -Not -Throw
    }

    It "Should have the proper amount of functions" {
        (Get-Command -Module ChocoCCM).Count | Should -Be 32
    }
}

#TODO: Lots of mocks for actual function tests