
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

        [Int32]$expectedWaitTimeoutMs = 10000


        Context 'When input parameters are valid' {


            Context 'When called with no parameter values' {

                It 'Should not throw' {

                    { Get-AzDevOpsApiWaitTimeoutMs } | Should -Not -Throw
                }

                It "Should output a 'Int32' type containing an 'WaitTimeoutMs' of '$expectedWaitTimeoutMs'" {

                    [Int32]$waitTimeoutMs = Get-AzDevOpsApiWaitTimeoutMs

                    $waitTimeoutMs | Should -BeExactly $expectedWaitTimeoutMs
                }
            }

        }


        Context "When input parameters are invalid" {

            # N/A - No parameters on this function/command

        }
    }
}
