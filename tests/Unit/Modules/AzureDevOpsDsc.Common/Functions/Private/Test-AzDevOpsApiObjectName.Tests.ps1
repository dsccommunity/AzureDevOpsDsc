
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsApiObjectName' -Tag 'TestAzDevOpsApiObjectName' {

        $testCasesValidObjectNames = @(
            @{
                ObjectName = 'Operation' },
            @{
                ObjectName = 'Project' }
        )

        $testCasesEmptyObjectNames = @(
            @{
                ObjectName = $null },
            @{
                ObjectName = '' }
        )

        $testCasesInvalidObjectNames = @(
            @{
                ObjectName = ' ' },
            @{
                ObjectName = 'a 1' },
            @{
                ObjectName = 'NonObject' },
            @{
                ObjectName = 'SomeOtherInvalidObject' }
        )

        Context 'When validating, valid "ObjectName" test cases' {

            It 'Should also be returned from "Get-AzDevOpsApiObjectName" function - <ObjectName>' -TestCases $testCasesValidObjectNames {
                param ([string]$ObjectName)

                $($(Get-AzDevOpsApiObjectName |
                    Where-Object { $_ -ceq $ObjectName})) | Should -Be $ObjectName

            }

        }

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ObjectName" parameter' {

                    It 'Should not throw - "<ObjectName>"' -TestCases $testCasesValidObjectNames {
                        param ([string]$ObjectName)

                        { Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ObjectName>"' -TestCases $testCasesValidObjectNames {
                        param ([string]$ObjectName)

                        $result = Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ObjectName" parameter' {

                    It 'Should throw - "<ObjectName>"' -TestCases $testCasesEmptyObjectNames {
                        param ([string]$ObjectName)

                        { Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ObjectName>"' -TestCases $testCasesInvalidObjectNames {
                        param ([string]$ObjectName)

                        { Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ObjectName>"' -TestCases $testCasesInvalidObjectNames {
                        param ([string]$ObjectName)

                        $result = Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ObjectName" parameter' {

                    It 'Should throw - "<ObjectName>"' -TestCases $testCasesValidObjectNames {
                        param ([string]$ObjectName)

                        { Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ObjectName" parameter' {

                    It 'Should throw - "<ObjectName>"' -TestCases $testCasesEmptyObjectNames {
                        param ([string]$ObjectName)

                        { Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ObjectName>"' -TestCases $testCasesInvalidObjectNames {
                        param ([string]$ObjectName)

                        { Test-AzDevOpsApiObjectName -ObjectName $ObjectName -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
