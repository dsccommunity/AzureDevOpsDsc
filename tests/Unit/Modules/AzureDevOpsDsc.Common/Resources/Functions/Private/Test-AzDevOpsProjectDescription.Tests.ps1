
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsProjectDescription' -Tag 'TestAzDevOpsProjectDescription' {

        $testCasesValidProjectDescriptions = Get-TestCase -ScopeName 'ProjectDescription' -TestCaseName 'Valid'
        $testCasesEmptyProjectDescriptions = Get-TestCase -ScopeName 'ProjectDescription' -TestCaseName 'Empty'
        $testCasesInvalidProjectDescriptions = Get-TestCase -ScopeName 'ProjectDescription' -TestCaseName 'Invalid'

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ProjectDescription" parameter' {

                    It 'Should not throw - "<ProjectDescription>"' -TestCases $testCasesValidProjectDescriptions {
                        param ([string]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ProjectDescription>"' -TestCases $testCasesValidProjectDescriptions {
                        param ([string]$ProjectDescription)

                        $result = Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ProjectDescription" parameter' {

                    It 'Should not throw - "<ProjectDescription>"' -TestCases $testCasesInvalidProjectDescriptions {
                        param ([string]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ProjectDescription>"' -TestCases $testCasesInvalidProjectDescriptions {
                        param ([string]$ProjectDescription)

                        $result = Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            $testCasesValidProjectDescriptions = Get-TestCase -ScopeName 'ProjectDescription' -TestCaseName 'Valid'

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ProjectDescription" parameter' {

                    It 'Should throw - "<ProjectDescription>"' -TestCases $testCasesValidProjectDescriptions {
                        param ([string]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ProjectDescription" parameter' {

                    It 'Should throw - "<ProjectDescription>"' -TestCases $testCasesEmptyProjectDescriptions {
                        param ([string]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ProjectDescription>"' -TestCases $testCasesInvalidProjectDescriptions {
                        param ([string]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
