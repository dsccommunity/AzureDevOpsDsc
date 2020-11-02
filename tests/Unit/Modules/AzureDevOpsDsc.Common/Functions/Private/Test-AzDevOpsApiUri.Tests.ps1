
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsApiUri' -Tag 'TestAzDevOpsApiUri' {

        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesEmptyApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Empty'
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ApiUri" parameter' {

                    It 'Should not throw - "<ApiUri>"' -TestCases $testCasesValidApiUris {
                        param ([string]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ApiUri>"' -TestCases $testCasesValidApiUris {
                        param ([string]$ApiUri)

                        $result = Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {

                    It 'Should throw - "<ApiUri>"' -TestCases $testCasesEmptyApiUris {
                        param ([string]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ApiUri>"' -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ApiUri>"' -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $result = Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ApiUri" parameter' {

                    It 'Should throw - "<ApiUri>"' -TestCases $testCasesValidApiUris {
                        param ([string]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ApiUri" parameter' {

                    It 'Should throw - "<ApiUri>"' -TestCases $testCasesEmptyApiUris {
                        param ([string]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ApiUri>"' -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
