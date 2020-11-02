
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsOperation' -Tag 'GetAzDevOpsOperation' {

        Context 'When called with valid parameters' {
            BeforeAll {
                Mock -ModuleName $script:subModuleName Get-AzDevOpsApiObject {
                    return $(Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid') |
                        ForEach-Object {
                            @{
                                id = $_.OperationId
                            }
                        }
                }
            }


            $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
            $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
            $testCasesValidApiUriPatCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUris, $testCasesValidPats

            $testCasesValidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
            $testCasesValidApiUriPatOperationIdCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesValidOperationIds


            Context 'When called with no "OperationId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    $result = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat | Out-Null
                    Should -Invoke Get-AzDevOpsApiObject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

            }


            Context 'When called with a "OperationId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    $result = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId | Out-Null
                    Should -Invoke Get-AzDevOpsApiObject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

                Context 'When a "Operation" with supplied "OperationId" parameter value does not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                        param ([string]$ApiUri, [string]$Pat)

                        $result = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId '114bff8d-6169-45cf-b085-fe121267e7aa' # Non-present "OperationId"
                        $result | Should -Be $null
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

                        { Get-AzDevOpsOperation -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with valid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $validApiUri = 'https://someuri.api/_apis/'
                        { Get-AzDevOpsOperation -ApiUri $validApiUri -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $invalidApiUri = 'someInvalidApiUrl'
                        { Get-AzDevOpsOperation -ApiUri $invalidApiUri -Pat $Pat } | Should -Throw

                    }
                }
            }

            Context 'When called with invalid "ApiUri" parameter' {

                $testCasesEmptyApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Empty'
                $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'

                Context 'When called without "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        { Get-AzDevOpsOperation -ApiUri $ApiUri } | Should -Throw

                    }
                }

                Context 'When called with valid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $validPat = '1234567890123456789012345678901234567890123456789012'
                        { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $validPat } | Should -Throw

                    }
                }

                Context 'When called with invalid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $invalidPat = '123456789012'
                        { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $invalidPat } | Should -Throw

                    }
                }
            }
        }

    }

}
