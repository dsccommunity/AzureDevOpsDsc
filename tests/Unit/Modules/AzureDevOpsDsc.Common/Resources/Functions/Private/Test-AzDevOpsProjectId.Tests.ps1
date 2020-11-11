
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Valid'
        $testCasesInvalidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ProjectId" parameter value and the "IsValid" switch' {


                Context 'When "ProjectId" parameter value is a valid "ProjectId"' {

                    It 'Should not throw - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([System.String]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([System.String]$ProjectId)

                        Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ProjectId" parameter value is an invalid "ProjectId"' {

                    It 'Should not throw - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([System.String]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([System.String]$ProjectId)

                        Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsProjectId -ProjectId:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "ProjectId" parameter value is a valid "ProjectId"' {


                Context 'When called with "ProjectId" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectId>"' -TestCases $testCasesValidProjectIds {
                        param ([System.String]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ProjectId" parameter value is an invalid "ProjectId"' {


                Context 'When called with "ProjectId" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectId>"' -TestCases $testCasesInvalidProjectIds {
                        param ([System.String]$ProjectId)

                        { Test-AzDevOpsProjectId -ProjectId $ProjectId -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
