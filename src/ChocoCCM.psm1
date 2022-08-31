# NOTE: This is a dev-time module file only. It will not be present when the
# module is published. To add items to the main PSM1 for the module, add code to
# the `module.psm1` script.

$filesToImport = Get-Item @(
    "$PSScriptRoot\module.psm1"
    "$PSScriptRoot\Public\*.ps1"
    "$PSScriptRoot\Private\*.ps1"
)

$filesToImport | ForEach-Object { . $_.FullName }
