
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

        $testCasesTimeoutExceeded = @(
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 1)
                EndTime = [DateTime]::new(2020,11,12, 09,35,00, 252) # 1ms longer than timeout
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2020,11,12, 09,35,01, 0) # 1s longer than timeout
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2020,11,12, 09,35,01, 0) # 1s longer than timeout
                TimeoutMs = 999 # Almost 1 second
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 1)
                EndTime = [DateTime]::new(2020,11,12, 09,36,00, 1) # 1m longer than timeout
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 999)
                EndTime = [DateTime]::new(2020,11,12, 10,35,00, 999) # 1h longer than timeout
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2020,11,13, 09,35,00, 0) # 1 day longer than timeout
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2020,12,12, 09,35,00, 0) # 1 month longer than timeout
                TimeoutMs = 500
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2021,11,12, 09,35,00, 0) # 1 year longer than timeout
                TimeoutMs = 300000
            }
        )
        $testCasesTimeoutNotExceeded = @(
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2020,11,12, 09,35,00, 0) # Identical to StartTime
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 1)
                EndTime = [DateTime]::new(2020,11,12, 09,35,00, 1) # Identical to StartTime
                TimeoutMs = 500
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 1)
                EndTime = [DateTime]::new(2020,11,12, 09,35,00, 250) # 1ms shorter than timeout (compared to StartTime)
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2020,11,12, 09,35,00, 249) # 1ms shorter than timeout (compared to StartTime)
                TimeoutMs = 250
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
                EndTime = [DateTime]::new(2020,11,12, 09,35,01, 0) # 1s longer than timeout
                TimeoutMs = 1000 # 1 second
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 502)
                EndTime = [DateTime]::new(2020,11,12, 09,35,00, 1) # EndTime 501ms before StartTime (negative timespan)
                TimeoutMs = 550
            },
            @{
                StartTime = [DateTime]::new(2020,11,12, 09,35,00, 501)
                EndTime = [DateTime]::new(2020,11,12, 09,35,00, 0) # EndTime 501ms before StartTime (negative timespan)
                TimeoutMs = 500
            }
        )


        Context 'When input parameters are valid' {


            Context 'When called with mandatory "StartTime", "EndTime" and "TimeoutMs" parameter values' {

                Context 'When called with values that should generate an exceeded timeout' {

                    It 'Should not throw - "<StartTime>","<EndTime>","<TimeoutMs>"' -TestCases $testCasesTimeoutExceeded {
                        param ([Datetime]$StartTime, [Datetime]$EndTime, [Int32]$TimeoutMs)

                        { Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs } | Should -Not -Throw
                    }

                    It 'Should return $true - "<StartTime>","<EndTime>","<TimeoutMs>"' -TestCases $testCasesTimeoutExceeded {
                        param ([Datetime]$StartTime, [Datetime]$EndTime, [Int32]$TimeoutMs)

                        Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs | Should -BeTrue
                    }
                }

                Context 'When called with values that should not generate an exceeded timeout' {

                    It 'Should not throw - "<StartTime>","<EndTime>","<TimeoutMs>"' -TestCases $testCasesTimeoutNotExceeded {
                        param ([Datetime]$StartTime, [Datetime]$EndTime, [Int32]$TimeoutMs)

                        { Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs } | Should -Not -Throw
                    }

                    It 'Should return $false - "<StartTime>","<EndTime>","<TimeoutMs>"' -TestCases $testCasesTimeoutNotExceeded {
                        param ([Datetime]$StartTime, [Datetime]$EndTime, [Int32]$TimeoutMs)

                        Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {

            [DateTime]$testTime = [DateTime]::new(2020,11,12, 09,35,00, 0)
            [Int32]$testTimeoutMs = 250

            Context 'When called with no/null parameter values' {

                It 'Should throw' {

                    { Test-AzDevOpsApiTimeoutExceeded -StartTime $null -EndTime $null -TimeoutMs $null } | Should -Throw
                }
            }

            Context 'When called with no/null "StartTime" parameter value' {

                It 'Should throw' {

                    { Test-AzDevOpsApiTimeoutExceeded -StartTime $null -EndTime $testTime -TimeoutMs $testTimeoutMs } | Should -Throw
                }
            }

            Context 'When called with no/null "EndTime" parameter value' {

                It 'Should throw' {

                    { Test-AzDevOpsApiTimeoutExceeded -StartTime $testTime -EndTime $null -TimeoutMs $testTimeoutMs } | Should -Throw
                }
            }

            Context 'When called with no/null "StartTime" and "EndTime" parameter values' {

                It 'Should throw' {

                    { Test-AzDevOpsApiTimeoutExceeded -StartTime $null -EndTime $null -TimeoutMs $testTimeoutMs } | Should -Throw
                }
            }

            Context 'When called with no/null "TimeoutMs" parameter value' {

                It 'Should throw' {

                    { Test-AzDevOpsApiTimeoutExceeded -StartTime $testTime -EndTime $testTime -TimeoutMs $null } | Should -Throw
                }
            }

            Context 'When called with no/null "StartTime" and "TimeoutMs" parameter values' {

                It 'Should throw' {

                    { Test-AzDevOpsApiTimeoutExceeded -StartTime $null -EndTime $testTime -TimeoutMs $null } | Should -Throw
                }
            }

            Context 'When called with no/null "EndTime" and "TimeoutMs" parameter values' {

                It 'Should throw' {

                    { Test-AzDevOpsApiTimeoutExceeded -StartTime $testTime -EndTime $null -TimeoutMs $null } | Should -Throw
                }
            }
        }
    }
}
