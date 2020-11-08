
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsOperation' -Tag 'GetAzDevOpsOperation' {

        Context 'When called with valid parameters' {
            BeforeEach {
                $mockOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
                $mockSucceededOperationId = $mockOperationIds[0].OperationId
                $mockCancelledOperationId = $mockOperationIds[1].OperationId
                $mockFailedOperationId = $mockOperationIds[2].OperationId
                $mockOperations = $mockOperationIds

                Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                    return $mockOperations | ForEach-Object {
                        @{
                            id = $_.OperationId
                            status = & {
                                switch ($_.OperationId)
                                {
                                    $mockSucceededOperationId {
                                        return 'succeeded'
                                        break
                                    }
                                    $mockCancelledOperationId {
                                        break
                                        return 'cancelled'
                                    }
                                    $mockFailedOperationId {
                                        break
                                        return 'failed'
                                    }
                                    default {
                                        return 'inProgress'
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }


            $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
            $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
            $testCasesValidApiUriPatCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUris, $testCasesValidPats

            $testCasesValidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
            $testCasesValidApiUriPatOperationIdCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesValidOperationIds


            Context 'When called with an "OperationId" parameter but with no "IsComplete" switch and no "IsSuccessful" switch' {

                It 'Should throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId } | Should -Throw
                }

            }


            Context 'When called with an "OperationId" parameter but with both an "IsComplete" switch and an "IsSuccessful" switch' {

                It 'Should throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete -IsSuccessful } | Should -Throw
                }

            }


            Context 'When called with an "OperationId" parameter and just the "IsSuccessful" switch' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful } | Should -Not -Throw
                }

                It 'Should return "bool" - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful
                    $result.GetType() | Should -BeIn $([System.Boolean]::new()).GetType()
                }

                It 'Should call "Get-AzDevOpsOperation" function atleast once - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful | Out-Null
                    Should -Invoke Get-AzDevOpsOperation -ModuleName $script:subModuleName -Times 1 -Scope It
                }

                Context 'When an "Operation" with supplied "OperationId" parameter value does not exist' {

                    BeforeEach {
                        Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                            return @(@{})
                        }
                    }

                    It 'Should return $false - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                        param ([string]$ApiUri, [string]$Pat)

                        $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId '114bff8d-6169-45cf-b085-fe121117e7aa' -IsSuccessful # Non-present "OperationId"
                        $result | Should -BeFalse
                    }
                }

                Context 'When a "Operation" with supplied "OperationId" parameter value does exist' {

                    Context 'When the "Operation" present has a "status" of "succeeded"' {

                        BeforeEach {

                            Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                                return @{
                                    id = $mockSucceededOperationId
                                    status = 'succeeded'
                                        }
                            }
                        }

                        It 'Should return $true - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                            param ([string]$ApiUri, [string]$Pat)

                            $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $mockSucceededOperationId -IsSuccessful
                            $result | Should -BeTrue
                        }
                    }

                    Context 'When the "Operation" present has a "status" of "cancelled"' {

                        BeforeEach {

                            Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                                return @{
                                    id = $mockCancelledOperationId
                                    status = 'cancelled'
                                        }
                            }
                        }

                        It 'Should return $false - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                            param ([string]$ApiUri, [string]$Pat)

                            $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $mockCancelledOperationId -IsSuccessful
                            $result | Should -BeFalse
                        }
                    }

                    Context 'When the "Operation" present has a "status" of "failed"' {

                        BeforeEach {

                            Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                                return @{
                                    id = $mockFailedOperationId
                                    status = 'failed'
                                        }
                            }
                        }

                        It 'Should return $false - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                            param ([string]$ApiUri, [string]$Pat)

                            $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $mockFailedOperationId -IsSuccessful
                            $result | Should -BeFalse
                        }
                    }
                }

            }




            Context 'When called with an "OperationId" parameter and just the "IsComplete" switch' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete } | Should -Not -Throw
                }

                It 'Should return "bool" - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete
                    $result.GetType() | Should -BeIn $([System.Boolean]::new()).GetType()
                }

                It 'Should call "Get-AzDevOpsOperation" function atleast once - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete | Out-Null
                    Should -Invoke Get-AzDevOpsOperation -ModuleName $script:subModuleName -Times 1 -Scope It
                }

                Context 'When a "Operation" with supplied "OperationId" parameter value does not exist' {

                    BeforeEach {

                        Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                            return @(@{})
                        }
                    }
                    It 'Should return $false - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                        param ([string]$ApiUri, [string]$Pat)

                        $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId '114bff8d-6169-45cf-b085-fe121267e7aa' -IsComplete # Non-present "OperationId"
                        $result | Should -BeFalse
                    }
                }

                Context 'When a "Operation" with supplied "OperationId" parameter value does exist' {

                    Context 'When the "Operation" present has a "status" of "succeeded"' {

                        BeforeEach {

                            Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                                return @{
                                    id = $mockSucceededOperationId
                                    status = 'succeeded'
                                        }
                            }
                        }

                        It 'Should return $true - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                            param ([string]$ApiUri, [string]$Pat)

                            $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $mockSucceededOperationId -IsComplete
                            $result | Should -BeTrue
                        }
                    }

                    Context 'When the "Operation" present has a "status" of "cancelled"' {

                        BeforeEach {

                            Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                                return @{
                                    id = $mockCancelledOperationId
                                    status = 'cancelled'
                                        }
                            }
                        }

                        It 'Should return $true - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                            param ([string]$ApiUri, [string]$Pat)

                            $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $mockCancelledOperationId -IsComplete
                            $result | Should -BeTrue
                        }
                    }

                    Context 'When the "Operation" present has a "status" of "failed"' {

                        BeforeEach {

                            Mock -ModuleName $script:subModuleName Get-AzDevOpsOperation {

                                return @{
                                    id = $mockFailedOperationId
                                    status = 'failed'
                                        }
                            }
                        }

                        It 'Should return $true - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                            param ([string]$ApiUri, [string]$Pat)

                            $result = Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $mockFailedOperationId -IsComplete
                            $result | Should -BeTrue
                        }
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called with invalid "Pat" parameter' {

                $testCasesEmptyPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Empty'
                $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'

                Context 'When called without "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsOperation -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with valid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $validApiUri = 'https://someuri.api/_apis/'
                        { Test-AzDevOpsOperation -ApiUri $validApiUri -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $invalidApiUri = 'someInvalidApiUrl'
                        { Test-AzDevOpsOperation -ApiUri $invalidApiUri -Pat $Pat } | Should -Throw

                    }
                }
            }

            Context 'When called with invalid "ApiUri" parameter' {

                $testCasesEmptyApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Empty'
                $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'

                Context 'When called without "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        { Test-AzDevOpsOperation -ApiUri $ApiUri } | Should -Throw

                    }
                }

                Context 'When called with valid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $validPat = '1234567890123456789012345678901234567890123456789012'
                        { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $validPat } | Should -Throw

                    }
                }

                Context 'When called with invalid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $invalidPat = '123456789012'
                        { Test-AzDevOpsOperation -ApiUri $ApiUri -Pat $invalidPat } | Should -Throw

                    }
                }
            }
        }

    }

}
