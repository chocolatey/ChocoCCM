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

    It "Should export all expected public functions" {
        $ExportedFunctions = (Get-Command -Module ChocoCCM -CommandType Function).Name | Sort-Object

        $DataFile = Import-Metadata -Path "$PSScriptRoot\..\ChocoCCM.psd1"
        $ExpectedFunctions = $DataFile.FunctionsToExport | Sort-Object

        $ExportedFunctions | Should -Be $ExpectedFunctions
    }
}
