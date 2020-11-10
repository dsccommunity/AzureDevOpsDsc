
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        [Int32]$expectedWaitIntervalMs = 500


        Context 'When input parameters are valid' {


            Context 'When called with no parameter values' {

                It 'Should not throw' {

                    { Get-AzDevOpsApiWaitIntervalMs } | Should -Not -Throw
                }

                It "Should output a 'Int32' type containing an 'WaitIntervalMs' of '$expectedWaitIntervalMs'" {

                    [Int32]$waitIntervalMs = Get-AzDevOpsApiWaitIntervalMs

                    $waitIntervalMs | Should -BeExactly $expectedWaitIntervalMs
                }
            }

        }


        Context "When input parameters are invalid" {

            # N/A - No parameters on this function/command

        }
    }
}
