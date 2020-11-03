
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsOperationId' -Tag 'TestAzDevOpsOperationId' {

        $testCasesValidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
        $testCasesEmptyOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Empty'
        $testCasesInvalidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Invalid'

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "OperationId" parameter' {

                    It 'Should not throw - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([string]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([string]$OperationId)

                        $result = Test-AzDevOpsOperationId -OperationId $OperationId -IsValid
                        $result | Should -Be $true
                    }

                    It 'Should return same as "Test-AzDevOpsApiObjectId" - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([string]$OperationId)

                        $result = Test-AzDevOpsOperationId -OperationId $OperationId -IsValid
                        $result | Should -Be $(Test-AzDevOpsApiObjectId -ObjectId $OperationId -IsValid)
                    }
                }

                Context 'When called with invalid "OperationId" parameter' {

                    It 'Should throw - "<OperationId>"' -TestCases $testCasesEmptyOperationIds {
                        param ([string]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([string]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([string]$OperationId)

                        $result = Test-AzDevOpsOperationId -OperationId $OperationId -IsValid
                        $result | Should -Be $false
                    }

                    It 'Should return same as "Test-AzDevOpsApiObjectId" - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([string]$OperationId)

                        $result = Test-AzDevOpsOperationId -OperationId $OperationId -IsValid
                        $result | Should -Be $(Test-AzDevOpsApiObjectId -ObjectId $OperationId -IsValid)
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "OperationId" parameter' {

                    It 'Should throw - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([string]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "OperationId" parameter' {

                    It 'Should throw - "<OperationId>"' -TestCases $testCasesEmptyOperationIds {
                        param ([string]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([string]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
