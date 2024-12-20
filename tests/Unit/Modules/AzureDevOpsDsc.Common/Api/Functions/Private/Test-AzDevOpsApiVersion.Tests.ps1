
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\builtModule\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Api\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidApiVersions = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Valid'
        $testCasesInvalidApiVersions = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ApiVersion" parameter value and the "IsValid" switch' {


                Context 'When "ApiVersion" parameter value is a valid "ApiVersion"' {

                    It 'Should not throw - "<ApiVersion>"' -TestCases $testCasesValidApiVersions {
                        param ([System.String]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ApiVersion>"' -TestCases $testCasesValidApiVersions {
                        param ([System.String]$ApiVersion)

                        Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ApiVersion" parameter value is an invalid "ApiVersion"' {

                    It 'Should not throw - "<ApiVersion>"' -TestCases $testCasesInvalidApiVersions {
                        param ([System.String]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ApiVersion>"' -TestCases $testCasesInvalidApiVersions {
                        param ([System.String]$ApiVersion)

                        Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsApiVersion -ApiVersion:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "ApiVersion" parameter value is a valid "ApiVersion"' {


                Context 'When called with "ApiVersion" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ApiVersion>"' -TestCases $testCasesValidApiVersions {
                        param ([System.String]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ApiVersion" parameter value is an invalid "ApiVersion"' {


                Context 'When called with "ApiVersion" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ApiVersion>"' -TestCases $testCasesInvalidApiVersions {
                        param ([System.String]$ApiVersion)

                        { Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
