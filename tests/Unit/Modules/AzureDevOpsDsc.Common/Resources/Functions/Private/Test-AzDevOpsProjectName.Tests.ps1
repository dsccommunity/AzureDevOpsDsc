
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Valid'
        $testCasesInvalidProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ProjectName" parameter value and the "IsValid" switch' {


                Context 'When "ProjectName" parameter value is a valid "ProjectName"' {

                    It 'Should not throw - "<ProjectName>"' -TestCases $testCasesValidProjectNames {
                        param ([System.String]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true' -TestCases $testCasesValidProjectNames {
                        param ([System.String]$ProjectName)

                        Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ProjectName" parameter value is an invalid "ProjectName"' {

                    It 'Should not throw - "<ProjectName>"' -TestCases $testCasesInvalidProjectNames {
                        param ([System.String]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false' -TestCases $testCasesInvalidProjectNames {
                        param ([System.String]$ProjectName)

                        Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsProjectName -ProjectName:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "ProjectName" parameter value is a valid "ProjectName"' {


                Context 'When called with "ProjectName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesValidProjectNames {
                        param ([System.String]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ProjectName" parameter value is an invalid "ProjectName"' {


                Context 'When called with "ProjectName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesInvalidProjectNames {
                        param ([System.String]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
