
# Initialize tests
. $PSScriptRoot\AzureDevOpsDsc.TestInitialization.ps1


InModuleScope 'AzureDevOpsDsc' {

    Describe 'DSCClassResources\AzDevOpsApiDscResourceBase' -Tag 'AzDevOpsApiDscResourceBase' {

        $dscModuleName = 'AzureDevOpsDsc'
        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesValidResourceNamesForDscResources = $testCasesValidResourceNames | Where-Object { $_.ResourceName -notin @('Operation')}

        Context "When evaluating '$dscModuleName' module" {
            BeforeAll {
                $dscModuleName = 'AzureDevOpsDsc'
                $dscResourcePrefix = 'AzDevOps'
                [string[]]$exportedDscResources = (Get-Module $dscModuleName).ExportedDscResources
            }

            It "Should contain an exported, DSCResource specific to the 'ResourceName' - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                param ([string]$ResourceName)

                "$dscResourcePrefix$ResourceName" | Should -BeIn $exportedDscResources
            }

        }

    }
}
