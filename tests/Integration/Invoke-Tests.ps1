param(
    [Parameter(Mandatory)]
    [String]$TestFrameworkConfigurationPath
)

#
# Dot Source the Supporting Functions

$CurrentLocation = Get-Location

#Get-ChildItem -Path "$($CurrentLocation.Path)\Supporting\API" -Filter "*.ps1" | ForEach-Object { . $_.FullName }
#Get-ChildItem -Path "$($CurrentLocation.Path)\Supporting\APICalls" -Filter "*.ps1" | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$($CurrentLocation.Path)\Supporting\Functions" -Filter "*.ps1" | ForEach-Object { . $_.FullName }

#
# Firstly Initialize the test environment
. "$($CurrentLocation.Path)\Supporting\Initalize-TestFramework.ps1" -TestFrameworkConfigurationPath $TestFrameworkConfigurationPath

#
# Trigger the Tests

Invoke-Pester -Path "$PSScriptRoot\Resources"

#
# Tear down the test environment

. "$PSScriptRoot\Supporting\Teardown.ps1"
