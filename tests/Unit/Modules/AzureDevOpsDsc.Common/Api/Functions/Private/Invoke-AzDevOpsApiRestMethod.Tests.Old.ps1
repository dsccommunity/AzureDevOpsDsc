
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {

    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\$script:commandName" -Tag $script:tag {

        Context "When validating '$script:commandName' function/command parameter sets" {

            $testCasesValidParameterSetNames = @(
                @{
                    ParameterSetName = '__AllParameterSets'
                }
            )

            $testCasesValidParameterSetNames | ForEach-Object {

                $parameterSetName = $_.ParameterSetName

                Context "When validating '$script:commandName' function/command, '$parameterSetName' parameter set" {

                    Context "When validating the '$parameterSetName' parameter set" {

                        Mock Invoke-RestMethod {}
                        Mock Start-Sleep {}
                        Mock New-InvalidOperationException {}

                        $testCasesValidParameterSetValues = Get-ParameterSetTestCase -CommandName $script:commandName -ParameterSetName $parameterSetName -TestCaseName 'Valid'
                        $testCasesInvalidParameterSetValues = Get-ParameterSetTestCase -CommandName $script:commandName -ParameterSetName $parameterSetName -TestCaseName 'Invalid'

                        Context "When invoking with 'Valid', parameter set values" {

                            It "Should not throw - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $testCasesValidParameterSetValues {
                                param([Hashtable]$ParameterSetValues)

                                { Invoke-AzDevOpsApiRestMethod @ParameterSetValues } | Should -Not -Throw
                            }

                            $testCasesValidParameterSetValues | ForEach-Object {

                                $_.ParameterSetValues.Keys | ForEach-Object {

                                    $parameterName = $_
                                    $testCasesValidParameterValues = Get-TestCase -ScopeName $parameterName -TestCaseName 'Valid'
                                    $testCasesValidParameterSetValuesByParameterName = Join-TestCaseArray -Expand -TestCaseArray @($testCasesValidParameterSetValues, $testCasesValidParameterValues)

                                    It "Should not throw - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset> ('$parameterName' = '<$parameterName>')" -TestCases $testCasesValidParameterSetValuesByParameterName {
                                        param([Hashtable]$ParameterSetValues)

                                        { Invoke-AzDevOpsApiRestMethod @ParameterSetValues } | Should -Not -Throw
                                    }

                                }
                            }

                        }

                        Context "When invoking with 'Valid', parameter set values, per" {

                            It "Should not throw - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $testCasesValidParameterSetValues {
                                param([Hashtable]$ParameterSetValues)

                                { Invoke-AzDevOpsApiRestMethod @ParameterSetValues } | Should -Not -Throw
                            }

                        }

                        Context "When invoking with 'Invalid', parameter set values" {

                            It "Should throw - '<ParameterSetValuesKey>' - <ParameterSetValuesOffset>" -TestCases $testCasesInvalidParameterSetValues {
                                param([Hashtable]$ParameterSetValues)

                                { Invoke-AzDevOpsApiRestMethod @ParameterSetValues } | Should -Throw
                            }

                        }
                    }


                }

            }

        }

    }

}
