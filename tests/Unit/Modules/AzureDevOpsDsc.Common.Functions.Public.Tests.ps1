
# Initialize tests for module function
. $PSScriptRoot\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {

    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:publicCommandNames = $($(Get-Command -Module $script:subModuleName).Name) | Where-Object { $_ -ilike 'Get-*'} #| Select-Object -First 2

    [hashtable[]]$testCasesValidCommandParameterSetNames = $script:publicCommandNames | ForEach-Object {

        $CommandName = $_
        $ParameterSetName = '__AllParameterSets'
        $ParameterSetTestCases = $(Get-ParameterSetTestCase -CommandName $_ -ParameterSetName '__AllParameterSets' -TestCaseName 'Valid')

        $ParameterSetTestCases | ForEach-Object {
            [hashtable]$testCase = $_
            $testCase.Add('CommandName',$CommandName)
            $testCase.Add('ParameterSetName',$ParameterSetName)

            $testCase
        }
    }

    [hashtable[]]$testCasesInvalidCommandParameterSetNames = $script:publicCommandNames | ForEach-Object {

        $CommandName = $_
        $ParameterSetName = '__AllParameterSets'
        $ParameterSetTestCases = $(Get-ParameterSetTestCase -CommandName $_ -ParameterSetName '__AllParameterSets' -TestCaseName 'Invalid')

        $ParameterSetTestCases | ForEach-Object {
            [hashtable]$testCase = $_
            $testCase.Add('CommandName',$CommandName)
            $testCase.Add('ParameterSetName',$ParameterSetName)

            $testCase
        }
    }


    Describe "GENERIC $subModuleName\AzureDevOpsDsc.Common\*\Functions\Public" {


        Context "When validating function/command parameter sets" {

            BeforeEach {
                Mock Invoke-RestMethod {}
                Mock Start-Sleep {}
                Mock New-InvalidOperationException {}
            }

            Context "When invoking function/command with 'Valid', parameter set values" {

                It "Should not throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $testCasesValidCommandParameterSetNames {
                    param([string]$CommandName, [Hashtable]$ParameterSetValues)

                    { & $CommandName @ParameterSetValues } | Should -Not -Throw
                }
            }

            Context "When invoking function/command with 'Invalid', parameter set values" {

                It "Should throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $testCasesInvalidCommandParameterSetNames {
                    param([string]$CommandName, [Hashtable]$ParameterSetValues)

                    { & $CommandName @ParameterSetValues } | Should -Throw
                }

            }
        }

    }

}
