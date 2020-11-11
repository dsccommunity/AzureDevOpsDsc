
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ApiUri" parameter value and the "IsValid" switch' {


                Context 'When "ApiUri" parameter value is a valid "ApiUri"' {

                    It 'Should not throw - "<ApiUri>"' -TestCases $testCasesValidApiUris {
                        param ([System.String]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true' -TestCases $testCasesValidApiUris {
                        param ([System.String]$ApiUri)

                        Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ApiUri" parameter value is an invalid "ApiUri"' {

                    It 'Should not throw - "<ApiUri>"' -TestCases $testCasesInvalidApiUris {
                        param ([System.String]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false' -TestCases $testCasesInvalidApiUris {
                        param ([System.String]$ApiUri)

                        Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsApiUri -ApiUri:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "ApiUri" parameter value is a valid "ApiUri"' {


                Context 'When called with "ApiUri" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ApiUri>"' -TestCases $testCasesValidApiUris {
                        param ([System.String]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ApiUri" parameter value is an invalid "ApiUri"' {


                Context 'When called with "ApiUri" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ApiUri>"' -TestCases $testCasesInvalidApiUris {
                        param ([System.String]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
