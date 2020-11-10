
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
            $testCase.Add('ParameterNames',$_.ParameterSetValues.Keys)

            $testCase
        }
    }

    [hashtable[]]$testCasesValidCommandParameterSetNameValidParameterValues = $testCasesValidCommandParameterSetNames | Where-Object { $_.ParameterNames.Count -gt 0 } | ForEach-Object {

            $commandName = $_.CommandName
            $parameterNames = $_.ParameterNames

            # Note: Exclude any parameter sets that do not have any parameters and ensure only
            #       looping through the test cases for the 'CommandName' being looped through in outer loop
            $testCasesValidCommandParameterSetNames | Where-Object { $_.ParameterNames.Count -gt 0 -and $_.CommandName -eq $commandName } | ForEach-Object {

                    $testCase = $_

                    $parameterNames | ForEach-Object {

                        $parameterName = $_
                        $parameterValues = $(Get-TestCaseValue -ScopeName $parameterName -TestCaseName 'Valid')

                        $parameterValues | ForEach-Object {

                            $parameterValue = $_

                            $newTestCase = @{}
                            $testCase.Keys | ForEach-Object {
                                $newTestCase[$_] = $testCase[$_]
                            }
                            $newTestCase.Remove('ParameterSetValues')
                            $newTestCase.Add('ParameterSetValues',@{})
                            $testCase.ParameterSetValues.Keys | ForEach-Object {
                                $newTestCase.ParameterSetValues[$_] = $testCase.ParameterSetValues[$_]
                            }
                            $newTestCase.ParameterSetValues[$parameterName] = $parameterValue
                            $newTestCase.Add('ParameterValue',$parameterValue)
                            $newTestCase.Add('ParameterName',$parameterName)

                            $newTestCase

                        }
                    }
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
            $testCase.Add('ParameterNames',$_.Keys)

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

                It "Should not throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset> ('<ParameterName>' = '<ParameterValue>')" -TestCases $testCasesValidCommandParameterSetNameValidParameterValues {
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
