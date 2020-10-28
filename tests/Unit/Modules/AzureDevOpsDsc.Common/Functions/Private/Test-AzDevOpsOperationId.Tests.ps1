
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsOperationId' -Tag 'TestAzDevOpsOperationId' {

        $testCasesValidOperationIds = @(
            @{
                OperationId = 'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc3' },
            @{
                OperationId = '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0' },
            @{
                OperationId = '4fe84ba8-d9f9-4880-ad5e-e18c99a1b2b4' }
        )

        $testCasesEmptyOperationIds = @(
            @{
                OperationId = $null },
            @{
                OperationId = '' }
        )

        $testCasesInvalidOperationIds = @(
            @{
                OperationId = ' ' },
            @{
                OperationId = 'a 1' },
            @{
                OperationId = 'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc' },
            @{
                OperationId = '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0a' }
            @{
                OperationId = '74cd62c6554b014f5fa986fcb4eea2c4c1d0' }
        )

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

                    It 'Should return same as "Test-AzDevOpsObjectId" - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([string]$OperationId)

                        $result = Test-AzDevOpsOperationId -OperationId $OperationId -IsValid
                        $result | Should -Be $(Test-AzDevOpsObjectId -ObjectId $OperationId -IsValid)
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

                    It 'Should return same as "Test-AzDevOpsObjectId" - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([string]$OperationId)

                        $result = Test-AzDevOpsOperationId -OperationId $OperationId -IsValid
                        $result | Should -Be $(Test-AzDevOpsObjectId -ObjectId $OperationId -IsValid)
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
