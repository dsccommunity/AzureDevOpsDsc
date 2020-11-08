
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsApiResourceName' -Tag 'TestAzDevOpsApiResourceName' {

        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesEmptyResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Empty'
        $testCasesInvalidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'

        Context 'When validating, valid "ResourceName" test cases' {

            It 'Should also be returned from "Get-AzDevOpsApiResourceName" function - <ResourceName>' -TestCases $testCasesValidResourceNames {
                param ([string]$ResourceName)

                $($(Get-AzDevOpsApiResourceName |
                    Where-Object { $_ -ceq $ResourceName})) | Should -Be $ResourceName

            }

        }

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ResourceName" parameter' {

                    It 'Should not throw - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        $result = Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ResourceName" parameter' {

                    It 'Should throw - "<ResourceName>"' -TestCases $testCasesEmptyResourceNames {
                        param ([string]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                        param ([string]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                        param ([string]$ResourceName)

                        $result = Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ResourceName" parameter' {

                    It 'Should throw - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ResourceName" parameter' {

                    It 'Should throw - "<ResourceName>"' -TestCases $testCasesEmptyResourceNames {
                        param ([string]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                        param ([string]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
