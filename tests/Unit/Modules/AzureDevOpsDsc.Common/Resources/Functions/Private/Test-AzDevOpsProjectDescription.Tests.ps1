
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Resources\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidProjectDescriptions = Get-TestCase -ScopeName 'ProjectDescription' -TestCaseName 'Valid'
        $testCasesInvalidProjectDescriptions = Get-TestCase -ScopeName 'ProjectDescription' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "ProjectDescription" parameter value and the "IsValid" switch' {


                Context 'When "ProjectDescription" parameter value is a valid "ProjectDescription"' {

                    It 'Should not throw - "<ProjectDescription>"' -TestCases $testCasesValidProjectDescriptions {
                        param ([System.String]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ProjectDescription>"' -TestCases $testCasesValidProjectDescriptions {
                        param ([System.String]$ProjectDescription)

                        Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid | Should -BeTrue
                    }
                }


                Context 'When "ProjectDescription" parameter value is an invalid "ProjectDescription"' {

                    It 'Should not throw - "<ProjectDescription>"' -TestCases $testCasesInvalidProjectDescriptions {
                        param ([System.String]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ProjectDescription>"' -TestCases $testCasesInvalidProjectDescriptions {
                        param ([System.String]$ProjectDescription)

                        Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsProjectDescription -ProjectDescription:$null -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "ProjectDescription" parameter value is a valid "ProjectDescription"' {


                Context 'When called with "ProjectDescription" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectDescription>"' -TestCases $testCasesValidProjectDescriptions {
                        param ([System.String]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "ProjectDescription" parameter value is an invalid "ProjectDescription"' {


                Context 'When called with "ProjectDescription" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<ProjectDescription>"' -TestCases $testCasesInvalidProjectDescriptions {
                        param ([System.String]$ProjectDescription)

                        { Test-AzDevOpsProjectDescription -ProjectDescription $ProjectDescription -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
