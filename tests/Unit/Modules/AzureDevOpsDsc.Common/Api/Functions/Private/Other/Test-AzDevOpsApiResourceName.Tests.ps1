
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Api\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


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

                    It 'Should return $true - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                        param ([System.String]$ResourceName)

                        Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ResourceName" parameter value is an invalid "ResourceName"' {

                    It 'Should not throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                        param ([System.String]$ResourceName)

                        { Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                        param ([System.String]$ResourceName)

                        Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsApiResourceName -ResourceName:$null -IsValid:$false } | Should -Throw
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
