
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Resources\Functions\Public\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Resources\Functions\Public\$script:commandName" -Tag $script:tag {


        # Mock functions called in function
        Mock Get-AzDevOpsOperation {}

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
        $testCasesValidApiUriPatOperationIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidOperationIds) -Expand
        $testCasesValidApiUriPatOperationIds3 = $testCasesValidApiUriPatOperationIds | Select-Object -First 3

        $validApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Valid' -First 1

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatOperationIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidOperationIds) -Expand
        $testCasesInvalidApiUriPatOperationIds3 = $testCasesInvalidApiUriPatOperationIds | Select-Object -First 3

        $invalidApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Invalid' -First 1


        Context 'When input parameters are valid' {


            Context 'When called with mandatory "ApiUri", "Pat" and "OperationId" parameters' {


                Context 'When also called with both "IsComplete" switch' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                        { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete } | Should -Not -Throw
                    }

                    It 'Should invoke "Get-AzDevOpsOperation" only once - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                        Mock Get-AzDevOpsOperation {} -Verifiable

                        Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                        Assert-MockCalled 'Get-AzDevOpsOperation' -Times 1 -Exactly -Scope 'It'
                    }


                    Context 'When "Operation" has completed' {

                        Context 'When status" of "Operation" is "succeeded"' {

                            It 'Should return $true - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                                Mock Get-AzDevOpsOperation {
                                    return $([PSObject]@{
                                        status = 'succeeded'
                                    })
                                }

                                Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete | Should -BeTrue
                            }
                        }

                        Context 'When status" of "Operation" is "cancelled"' {

                            It 'Should return $true - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                                Mock Get-AzDevOpsOperation {
                                    return $([PSObject]@{
                                        status = 'cancelled'
                                    })
                                }

                                Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete | Should -BeTrue
                            }
                        }

                        Context 'When status" of "Operation" is "failed"' {

                            It 'Should return $true - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                                Mock Get-AzDevOpsOperation {
                                    return $([PSObject]@{
                                        status = 'failed'
                                    })
                                }

                                Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete | Should -BeTrue
                            }
                        }

                    }


                    Context 'When "Operation" has not completed' {

                        It 'Should return $false - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds {
                            param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                            Mock Get-AzDevOpsOperation {
                                return $([PSObject]@{
                                    status = 'AnyNonCompletedStatus'
                                })
                            }

                            Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete | Should -BeFalse
                        }
                    }
                }


                Context 'When also called with both "IsSuccessful" switch' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                        { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful } | Should -Not -Throw
                    }


                    Context 'When "Operation" has succeeded' {

                        It 'Should return $true - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                            Mock Get-AzDevOpsOperation {
                                return $([PSObject]@{
                                    status = 'succeeded'
                                })
                            }

                            Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful | Should -BeTrue
                        }
                    }


                    Context 'When "Operation" has not succeeded' {

                        It 'Should return $false - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                            Mock Get-AzDevOpsOperation {
                                return $([PSObject]@{
                                    status = 'ANotSucceededStatus'
                                })
                            }

                            Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful | Should -BeFalse
                        }
                    }
                }

            }
        }

        Context 'When input parameters are invalid' {


            Context 'When called with mandatory "ApiUri", "Pat" and "OperationId" parameters' {

                It 'Should throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete:$null } | Should -Throw
                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful:$null } | Should -Throw
                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete:$null -IsSuccessful:$null } | Should -Throw
                }

                Context 'When also called with both "IsComplete" and "IsSuccessful" switches' {

                    It 'Should throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                        { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete -IsSuccessful } | Should -Throw
                    }

                }

            }


            Context 'When called with invalid "ApiUri", "Pat" and "OperationId" parameters, and "IsComplete" switch' {

                It 'Should throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesInvalidApiUriPatOperationIds {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete } | Should -Throw
                }

            }


            Context 'When called with invalid "ApiUri", "Pat" and "OperationId" parameters, and "IsSuccessful" switch' {

                It 'Should throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesInvalidApiUriPatOperationIds {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful } | Should -Throw
                }

            }

        }








        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsProjectName -ProjectName:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "ProjectName" parameter value is a valid "ProjectName"' {


                Context 'When called with "ProjectName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesValidProjectNames {
                        param ([System.String]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ProjectName" parameter value is an invalid "ProjectName"' {


                Context 'When called with "ProjectName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesInvalidProjectNames {
                        param ([System.String]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
