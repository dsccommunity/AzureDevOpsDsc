
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsApiResourceId' -Tag 'TestAzDevOpsApiResourceId' {

        $testCasesValidResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Valid'
        $testCasesEmptyResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Empty'
        $testCasesInvalidResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Invalid'

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ResourceId" parameter' {

                    It 'Should not throw - "<ResourceId>"' -TestCases $testCasesValidResourceIds {
                        param ([string]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ResourceId>"' -TestCases $testCasesValidResourceIds {
                        param ([string]$ResourceId)

                        $result = Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ResourceId" parameter' {

                    It 'Should throw - "<ResourceId>"' -TestCases $testCasesEmptyResourceIds {
                        param ([string]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ResourceId>"' -TestCases $testCasesInvalidResourceIds {
                        param ([string]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ResourceId>"' -TestCases $testCasesInvalidResourceIds {
                        param ([string]$ResourceId)

                        $result = Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ResourceId" parameter' {

                    It 'Should throw - "<ResourceId>"' -TestCases $testCasesValidResourceIds {
                        param ([string]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ResourceId" parameter' {

                    It 'Should throw - "<ResourceId>"' -TestCases $testCasesEmptyResourceIds {
                        param ([string]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ResourceId>"' -TestCases $testCasesInvalidResourceIds {
                        param ([string]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
