
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\builtModule\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Resources\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


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

                    It 'Should return $true - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid | Should -BeTrue
                    }
                }


                Context 'When "OrganizationName" parameter value is an invalid "OrganizationName"' {

                    It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesInvalidOrganizationNames {
                        param ([System.String]$OrganizationName)

                        { Test-AzDevOpsOrganizationName -OrganizationName $OrganizationName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<OrganizationName>"' -TestCases $testCasesInvalidOrganizationNames {
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
