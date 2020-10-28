
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsObjectId' -Tag 'TestAzDevOpsObjectId' {

        $testCasesValidObjectIds = @(
            @{
                ObjectId = 'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc3' },
            @{
                ObjectId = '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0' },
            @{
                ObjectId = '4fe84ba8-d9f9-4880-ad5e-e18c99a1b2b4' }
        )

        $testCasesEmptyObjectIds = @(
            @{
                ObjectId = $null },
            @{
                ObjectId = '' }
        )

        $testCasesInvalidObjectIds = @(
            @{
                ObjectId = ' ' },
            @{
                ObjectId = 'a 1' },
            @{
                ObjectId = 'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc' },
            @{
                ObjectId = '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0a' }
            @{
                ObjectId = '74cd62c6554b014f5fa986fcb4eea2c4c1d0' }
        )

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ObjectId" parameter' {

                    It 'Should not throw - "<ObjectId>"' -TestCases $testCasesValidObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ObjectId>"' -TestCases $testCasesValidObjectIds {
                        param ([string]$ObjectId)

                        $result = Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ObjectId" parameter' {

                    It 'Should throw - "<ObjectId>"' -TestCases $testCasesEmptyObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ObjectId>"' -TestCases $testCasesInvalidObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ObjectId>"' -TestCases $testCasesInvalidObjectIds {
                        param ([string]$OrganizationName)

                        $result = Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid
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

                        { Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ObjectId" parameter' {

                    It 'Should throw - "<ObjectId>"' -TestCases $testCasesEmptyObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ObjectId>"' -TestCases $testCasesInvalidObjectIds {
                        param ([string]$ObjectId)

                        { Test-AzDevOpsObjectId -ObjectId $ObjectId -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
