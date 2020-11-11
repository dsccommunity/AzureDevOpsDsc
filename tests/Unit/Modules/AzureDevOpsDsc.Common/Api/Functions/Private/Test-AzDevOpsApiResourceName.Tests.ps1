
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesInvalidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ResourceName" parameter value and the "IsValid" switch' {


                Context 'When "ResourceName" parameter value is a valid "ResourceName"' {

                    It 'Should not throw - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                        param ([System.String]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true' -TestCases $testCasesValidResourceNames {
                        param ([System.String]$ResourceName)

                        Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ResourceName" parameter value is an invalid "ResourceName"' {

                    It 'Should not throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                        param ([System.String]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false' -TestCases $testCasesInvalidResourceNames {
                        param ([System.String]$ResourceName)

                        Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {
                    param ([System.String]$ResourceName)

                    { Test-AzDevOpsApiResourceName -ResourceName:$null } | Should -Throw
                }
            }


            Context 'When "ResourceName" parameter value is a valid "ResourceName"' {


                Context 'When called with "ResourceName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                        param ([System.String]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ResourceName" parameter value is an invalid "ResourceName"' {


                Context 'When called with "ResourceName" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                        param ([System.String]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
