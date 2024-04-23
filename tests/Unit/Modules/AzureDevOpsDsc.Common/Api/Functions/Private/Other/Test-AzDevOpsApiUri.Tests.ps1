
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

        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ApiUri" parameter value and the "IsValid" switch' {


                Context 'When "ApiUri" parameter value is a valid "ApiUri"' {

                    It 'Should not throw - "<ApiUri>"' -TestCases $testCasesValidApiUris {
                        param ([System.String]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ApiUri>"' -TestCases $testCasesValidApiUris {
                        param ([System.String]$ApiUri)

                        Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ApiUri" parameter value is an invalid "ApiUri"' {

                    It 'Should not throw - "<ApiUri>"' -TestCases $testCasesInvalidApiUris {
                        param ([System.String]$ApiUri)

                        { Test-AzDevOpsApiUri -ApiUri $ApiUri -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ApiUri>"' -TestCases $testCasesInvalidApiUris {
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
