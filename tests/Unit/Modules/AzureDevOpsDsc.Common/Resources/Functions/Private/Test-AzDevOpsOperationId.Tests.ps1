
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
        $testCasesInvalidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "OperationId" parameter value and the "IsValid" switch' {


                Context 'When "OperationId" parameter value is a valid "OperationId"' {

                    It 'Should not throw - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([System.String]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([System.String]$OperationId)

                        Test-AzDevOpsOperationId -OperationId $OperationId -IsValid | Should -BeTrue
                    }
                }


                Context 'When "OperationId" parameter value is an invalid "OperationId"' {

                    It 'Should not throw - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([System.String]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([System.String]$OperationId)

                        Test-AzDevOpsOperationId -OperationId $OperationId -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsOperationId -OperationId:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "OperationId" parameter value is a valid "OperationId"' {


                Context 'When called with "OperationId" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<OperationId>"' -TestCases $testCasesValidOperationIds {
                        param ([System.String]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "OperationId" parameter value is an invalid "OperationId"' {


                Context 'When called with "OperationId" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<OperationId>"' -TestCases $testCasesInvalidOperationIds {
                        param ([System.String]$OperationId)

                        { Test-AzDevOpsOperationId -OperationId $OperationId -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
