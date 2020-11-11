
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

        $testCasesValidResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Valid'
        $testCasesInvalidResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ResourceId" parameter value and the "IsValid" switch' {


                Context 'When "ResourceId" parameter value is a valid "ResourceId"' {

                    It 'Should not throw - "<ResourceId>"' -TestCases $testCasesValidResourceIds {
                        param ([System.String]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ResourceId>"' -TestCases $testCasesValidResourceIds {
                        param ([System.String]$ResourceId)

                        Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ResourceId" parameter value is an invalid "ResourceId"' {

                    It 'Should not throw - "<ResourceId>"' -TestCases $testCasesInvalidResourceIds {
                        param ([System.String]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ResourceId>"' -TestCases $testCasesInvalidResourceIds {
                        param ([System.String]$ResourceId)

                        Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsApiResourceId -ResourceId:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "ResourceId" parameter value is a valid "ResourceId"' {


                Context 'When called with "ResourceId" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ResourceId>"' -TestCases $testCasesValidResourceIds {
                        param ([System.String]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ResourceId" parameter value is an invalid "ResourceId"' {


                Context 'When called with "ResourceId" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ResourceId>"' -TestCases $testCasesInvalidResourceIds {
                        param ([System.String]$ResourceId)

                        { Test-AzDevOpsApiResourceId -ResourceId $ResourceId -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
