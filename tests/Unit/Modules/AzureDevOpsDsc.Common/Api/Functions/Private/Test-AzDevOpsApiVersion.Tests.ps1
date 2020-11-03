
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsApiVersion' -Tag 'TestAzDevOpsApiVersion' {

        $testCasesValidApiVersions = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Valid'
        $testCasesEmptyApiVersions = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Empty'
        $testCasesInvalidApiVersions = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Invalid'

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ApiVersion" parameter' {

                    It 'Should not throw - "<ApiVersion>"' -TestCases $testCasesValidApiVersions {
                        param ([string]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ApiVersion>"' -TestCases $testCasesValidApiVersions {
                        param ([string]$ApiVersion)

                        $result = Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ApiVersion" parameter' {

                    It 'Should throw - "<ApiVersion>"' -TestCases $testCasesEmptyApiVersions {
                        param ([string]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ApiVersion>"' -TestCases $testCasesInvalidApiVersions {
                        param ([string]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ApiVersion>"' -TestCases $testCasesInvalidApiVersions {
                        param ([string]$ApiVersion)

                        $result = Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ApiVersion" parameter' {

                    It 'Should throw - "<ApiVersion>"' -TestCases $testCasesValidApiVersions {
                        param ([string]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ApiVersion" parameter' {

                    It 'Should throw - "<ApiVersion>"' -TestCases $testCasesEmptyApiVersions {
                        param ([string]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ApiVersion>"' -TestCases $testCasesInvalidApiVersions {
                        param ([string]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
