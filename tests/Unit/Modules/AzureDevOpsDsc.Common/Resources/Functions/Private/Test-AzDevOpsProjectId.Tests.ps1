
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsProjectId' -Tag 'TestAzDevOpsProjectId' {

        $testCasesValidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Valid'
        $testCasesEmptyProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Empty'
        $testCasesInvalidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Invalid'

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

                    It 'Should return same as "Test-AzDevOpsApiResourceId" - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([string]$ProjectId)

                        $result = Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid
                        $result | Should -Be $(Test-AzDevOpsApiResourceId -ResourceId $ProjectId -IsValid)
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

                    It 'Should return same as "Test-AzDevOpsApiResourceId" - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([string]$ProjectId)

                        $result = Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid
                        $result | Should -Be $(Test-AzDevOpsApiResourceId -ResourceId $ProjectId -IsValid)
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
