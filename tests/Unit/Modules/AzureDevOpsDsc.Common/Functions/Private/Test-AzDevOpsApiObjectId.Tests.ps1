
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsApiObjectId' -Tag 'TestAzDevOpsApiObjectId' {

        $testCasesValidObjectIds = Get-TestCase -ScopeName 'ObjectId' -TestCaseName 'Valid'
        $testCasesEmptyObjectIds = Get-TestCase -ScopeName 'ObjectId' -TestCaseName 'Empty'
        $testCasesInvalidObjectIds = Get-TestCase -ScopeName 'ObjectId' -TestCaseName 'Invalid'

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ObjectId" parameter' {

                    It 'Should not throw - "<ObjectId>"' -TestCases $testCasesValidObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ObjectId>"' -TestCases $testCasesValidObjectIds {
                        param ([string]$ObjectId)

                        $result = Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ObjectId" parameter' {

                    It 'Should throw - "<ObjectId>"' -TestCases $testCasesEmptyObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ObjectId>"' -TestCases $testCasesInvalidObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ObjectId>"' -TestCases $testCasesInvalidObjectIds {
                        param ([string]$ObjectId)

                        $result = Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ObjectId" parameter' {

                    It 'Should throw - "<ObjectId>"' -TestCases $testCasesValidObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ObjectId" parameter' {

                    It 'Should throw - "<ObjectId>"' -TestCases $testCasesEmptyObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ObjectId>"' -TestCases $testCasesInvalidObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsApiObjectId -ObjectId $ObjectId -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
