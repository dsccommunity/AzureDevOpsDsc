
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

        $testCasesValidPatCredentials = Get-TestCase -ScopeName 'PatCredential' -TestCaseName 'Valid'
        $testCasesInvalidPatCredentials = Get-TestCase -ScopeName 'PatCredential' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "PatCredential" parameter value and the "IsValid" switch' {


                Context 'When "PatCredential" parameter value is a valid "PatCredential"' {

                    It 'Should not throw - "<PatCredential>"' -TestCases $testCasesValidPatCredentials {
                        param ([PSCredential]$PatCredential)

                        { Test-AzDevOpsPatCredential -PatCredential $PatCredential -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<PatCredential>"' -TestCases $testCasesValidPatCredentials {
                        param ([PSCredential]$PatCredential)

                        Test-AzDevOpsPatCredential -PatCredential $PatCredential -IsValid | Should -BeTrue
                    }
                }


                Context 'When "PatCredential" parameter value is an invalid "PatCredential"' {

                    It 'Should not throw - "<PatCredential>"' -TestCases $testCasesInvalidPatCredentials {
                        param ([PSCredential]$PatCredential)

                        { Test-AzDevOpsPatCredential -PatCredential $PatCredential -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<PatCredential>"' -TestCases $testCasesInvalidPatCredentials {
                        param ([PSCredential]$PatCredential)

                        Test-AzDevOpsPatCredential -PatCredential $PatCredential -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null/empty parameter values/switches' {

                It 'Should throw' {

                    { Test-AzDevOpsPatCredential -PatCredential $([PSCredential]::Empty) -IsValid:$false } | Should -Throw
                }
            }


            Context 'When "PatCredential" parameter value is a valid "PatCredential"' {


                Context 'When called with "PatCredential" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<PatCredential>"' -TestCases $testCasesValidPatCredentials {
                        param ([PSCredential]$PatCredential)

                        { Test-AzDevOpsPatCredential -PatCredential $PatCredential -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "PatCredential" parameter value is an invalid "PatCredential"' {


                Context 'When called with "PatCredential" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<PatCredential>"' -TestCases $testCasesInvalidPatCredentials {
                        param ([PSCredential]$PatCredential)

                        { Test-AzDevOpsPatCredential -PatCredential $PatCredential -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
