
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsOrganizationName' -Tag 'TestAzDevOpsOrganizationName' {

        $testCasesValidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Valid'
        $testCasesEmptyOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Empty'
        $testCasesInvalidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Invalid'

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "OrganizationName" parameter' {

                    It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                        param ([string]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                        param ([string]$OrganizationName)

                        $result = Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "OrganizationName" parameter' {

                    It 'Should throw - "<OrganizationName>"' -TestCases $testCasesEmptyOrganizationNames {
                        param ([string]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesInvalidOrganizationNames {
                        param ([string]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<OrganizationName>"' -TestCases $testCasesInvalidOrganizationNames {
                        param ([string]$OrganizationName)

                        $result = Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            $testCasesValidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Valid'

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "OrganizationName" parameter' {

                    It 'Should throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                        param ([string]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "OrganizationName" parameter' {

                    It 'Should throw - "<OrganizationName>"' -TestCases $testCasesEmptyOrganizationNames {
                        param ([string]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<OrganizationName>"' -TestCases $testCasesInvalidOrganizationNames {
                        param ([string]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
