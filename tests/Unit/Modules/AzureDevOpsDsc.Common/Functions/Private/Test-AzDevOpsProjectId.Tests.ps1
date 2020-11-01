
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsProjectId' -Tag 'TestAzDevOpsProjectId' {

        $testCasesValidProjectIds = @(
            @{
                ProjectId = 'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc3' },
            @{
                ProjectId = '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0' },
            @{
                ProjectId = '4fe84ba8-d9f9-4880-ad5e-e18c99a1b2b4' }
        )

        $testCasesEmptyProjectIds = @(
            @{
                ProjectId = $null },
            @{
                ProjectId = '' }
        )

        $testCasesInvalidProjectIds = @(
            @{
                ProjectId = ' ' },
            @{
                ProjectId = 'a 1' },
            @{
                ProjectId = 'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc' },
            @{
                ProjectId = '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0a' }
            @{
                ProjectId = '74cd62c6554b014f5fa986fcb4eea2c4c1d0' }
        )

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ProjectId" parameter' {

                    It 'Should not throw - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([string]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([string]$ProjectId)

                        $result = Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid
                        $result | Should -Be $true
                    }

                    It 'Should return same as "Test-AzDevOpsApiObjectId" - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([string]$ProjectId)

                        $result = Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid
                        $result | Should -Be $(Test-AzDevOpsApiObjectId -ObjectId $ProjectId -IsValid)
                    }
                }

                Context 'When called with invalid "ProjectId" parameter' {

                    It 'Should throw - "<ProjectId>"' -TestCases $testCasesEmptyProjectIds {
                        param ([string]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([string]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([string]$ProjectId)

                        $result = Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid
                        $result | Should -Be $false
                    }

                    It 'Should return same as "Test-AzDevOpsApiObjectId" - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([string]$ProjectId)

                        $result = Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid
                        $result | Should -Be $(Test-AzDevOpsApiObjectId -ObjectId $ProjectId -IsValid)
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ProjectId" parameter' {

                    It 'Should throw - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([string]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ProjectId" parameter' {

                    It 'Should throw - "<ProjectId>"' -TestCases $testCasesEmptyProjectIds {
                        param ([string]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([string]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
