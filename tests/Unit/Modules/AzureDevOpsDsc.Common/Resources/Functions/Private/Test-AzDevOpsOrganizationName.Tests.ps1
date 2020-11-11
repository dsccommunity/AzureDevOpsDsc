
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Valid'
        $testCasesInvalidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "OrganizationName" parameter value and the "IsValid" switch' {


                Context 'When "OrganizationName" parameter value is a valid "OrganizationName"' {

                    It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true' -TestCases $testCasesValidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid | Should -BeTrue
                    }
                }


                Context 'When "OrganizationName" parameter value is an invalid "OrganizationName"' {

                    It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesInvalidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false' -TestCases $testCasesInvalidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsOrganizationName -OrganizationName:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "OrganizationName" parameter value is a valid "OrganizationName"' {


                Context 'When called with "OrganizationName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "OrganizationName" parameter value is an invalid "OrganizationName"' {


                Context 'When called with "OrganizationName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<OrganizationName>"' -TestCases $testCasesInvalidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
