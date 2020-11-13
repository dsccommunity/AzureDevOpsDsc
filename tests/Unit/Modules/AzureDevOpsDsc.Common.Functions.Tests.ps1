
# Initialize tests for module function
. $PSScriptRoot\AzureDevOpsDsc.Common.Tests.Initialization.ps1

return

InModuleScope $script:subModuleName {

    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:publicCommandNames = $($(Get-Command -Module $script:subModuleName).Name)

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
                        $parameterValues = $(Get-TestCaseValue -ScopeName $parameterName -TestCaseName 'Valid' -First 1)

                        $parameterValues | ForEach-Object {

                            $parameterValue = $_

                            if ($testCase.ParameterSetValues.ContainsKey($parameterName)) # Only want to generate new records if 'ParameterName' is in the set of 'ParameterSetValues' keys
                            {
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

    [hashtable[]]$testCasesValidCommandParameterSetNameInvalidParameterValues = $testCasesValidCommandParameterSetNames | Where-Object { $_.ParameterNames.Count -gt 0 } | ForEach-Object {

        $commandName = $_.CommandName
        $parameterNames = $_.ParameterNames

        # Note: Exclude any parameter sets that do not have any parameters and ensure only
        #       looping through the test cases for the 'CommandName' being looped through in outer loop
        $testCasesValidCommandParameterSetNames | Where-Object { $_.ParameterNames.Count -gt 0 -and $_.CommandName -eq $commandName } | ForEach-Object {

                $testCase = $_

                $parameterNames | ForEach-Object {

                    $parameterName = $_
                    $parameterValues = $(Get-TestCaseValue -ScopeName $parameterName -TestCaseName 'Invalid' -First 1)

                    $parameterValues | ForEach-Object {

                        if ($testCase.ParameterSetValues.ContainsKey($parameterName)) # Only want to generate new records if 'ParameterName' is in the set of 'ParameterSetValues' keys
                        {
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
    }


    Describe "$subModuleName\AzureDevOpsDsc.Common\*\Functions" {


        Context "When validating function/command parameter sets" {

            BeforeEach {

                Mock Invoke-RestMethod {
                    return @{
                        id = '14c15b78-b85d-401f-8095-504c57bbd79e'
                    }
                }

                Mock Start-Sleep {}
                #Mock New-InvalidOperationException {} # Don't mock this. Want exception to be thrown by it.
            }

            Context "When invoking function/command with 'Valid', parameter set values" {

                It "Should not throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $testCasesValidCommandParameterSetNames {
                    param([string]$CommandName, [Hashtable]$ParameterSetValues)

                    Mock -CommandName $CommandName -MockWith {}
                    { & $CommandName @ParameterSetValues } | Should -Not -Throw
                }

                It "Should not throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset> ('<ParameterName>' = '<ParameterValue>')" -TestCases $testCasesValidCommandParameterSetNameValidParameterValues {
                    param([string]$CommandName, [Hashtable]$ParameterSetValues)

                    Mock -CommandName $CommandName -MockWith {}
                    { & $CommandName @ParameterSetValues } | Should -Not -Throw
                }
            }


            Context "When invoking function/command with 'Invalid', parameter set values" {

                Context "When 'IsValid' parameter name is not present" {

                    It "Should throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $($testCasesInvalidCommandParameterSetNames | Where-Object { $_.ParameterSetValuesKey -notlike '*IsValid*' }) {
                        param([string]$CommandName, [Hashtable]$ParameterSetValues)

                        Mock -CommandName $CommandName -MockWith {}
                        { & $CommandName @ParameterSetValues } | Should -Throw
                    }

                    It "Should throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $($testCasesInvalidCommandParameterSetNames | Where-Object { $_.ParameterSetValuesKey -notlike '*IsValid*' }){
                        param([string]$CommandName, [Hashtable]$ParameterSetValues)

                        Mock -CommandName $CommandName -MockWith {}
                        { & $CommandName @ParameterSetValues } | Should -Throw
                    }
                }

                Context "When 'IsValid' parameter name is present" {

                    # Don't want this to throw an exception - Typically they need to return a $false return value if input parameters are invalid.

                    It "Should not throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset> ('<ParameterName>' = '<ParameterValue>')" -TestCases $($testCasesValidCommandParameterSetNameInvalidParameterValues | Where-Object { $_.ParameterSetValuesKey -like '*IsValid*' }) {
                        param([string]$CommandName, [Hashtable]$ParameterSetValues)

                        Mock -CommandName $CommandName -MockWith {}
                        { & $CommandName @ParameterSetValues } | Should -Not -Throw
                    }

                    It "Should not throw - '<CommandName>' - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset> ('<ParameterName>' = '<ParameterValue>')" -TestCases $($testCasesValidCommandParameterSetNameInvalidParameterValues | Where-Object { $_.ParameterSetValuesKey -like '*IsValid*' }) {
                        param([string]$CommandName, [Hashtable]$ParameterSetValues)

                        Mock -CommandName $CommandName -MockWith {}
                        { & $CommandName @ParameterSetValues } | Should -Not -Throw
                    }

                }


            }
        }

    }

}
