
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Resources\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        # Get default, parameter values
        $defaultWaitIntervalMilliseconds = Get-AzDevOpsApiWaitIntervalMs
        $defaultWaitTimeoutMilliseconds = Get-AzDevOpsApiWaitTimeoutMs

        # Mock functions called in function
        Mock Get-AzDevOpsApiWaitIntervalMs {}
        Mock Get-AzDevOpsApiWaitTimeoutMs {}
        # Mock Get-Date {} # Do not mock
        # Mock New-InvalidOperationException {} # Do not mock
        Mock Start-Sleep {}
        Mock Test-AzDevOpsOperation {}
        Mock Test-AzDevOpsApiTimeoutExceeded {}

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
        $testCasesValidApiUriPatOperationIds3 = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidOperationIds) -Expand
        $testCasesValidApiUriPatOperationIds3 = $testCasesValidApiUriPatOperationIds3 | Select-Object -First 3

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatOperationIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidOperationIds) -Expand
        $testCasesInvalidApiUriPatOperationIds3 = $testCasesInvalidApiUriPatOperationIds | Select-Object -First 3


        Context 'When input parameters are valid' {


            Context "When called with all, mandatory parameters ('ApiUri', 'Pat' and 'OperationId')" {

                It "Should throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                    param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                    { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId } | Should -Throw
                }


                Context "When also called with mandatory, 'IsComplete', switch parameter" {
                    Mock Get-AzDevOpsApiWaitIntervalMs { return 250 }
                    Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 }
                    Mock Test-AzDevOpsOperation { return $true }

                    It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete } | Should -Not -Throw
                    }

                    It "Should output null/nothing - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        $output =  Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                        $output | Should -BeNullOrEmpty
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitIntervalMs' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                        Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                        Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 1 -Exactly -Scope It
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitTimeoutMs' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                        Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                        Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 1 -Exactly -Scope It
                    }


                    Context "When 'Test-AzDevOpsOperation' returns true" {

                        It "Should invoke 'Test-AzDevOpsOperation' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Test-AzDevOpsOperation { return $true } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                            Assert-MockCalled 'Test-AzDevOpsOperation' -Times 1 -Exactly -Scope It
                        }

                        It "Should invoke 'Get-Date' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                            Assert-MockCalled 'Get-Date' -Times 1 -Exactly -Scope It
                        }

                        It "Should not invoke 'Start-Sleep' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Start-Sleep {} -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                            Assert-MockCalled 'Start-Sleep' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Test-AzDevOpsApiTimeoutExceeded' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Test-AzDevOpsApiTimeoutExceeded {} -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                            Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 0 -Exactly -Scope It
                        }
                    }


                    Context "When 'Test-AzDevOpsOperation' returns false, then true" {


                        Context "When 'WaitTimeoutMilliseconds' has not been exceeded" {
                            Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                            Mock Test-AzDevOpsOperation {
                                $script:mockTestAzDevOpsOperationInvoked = !($script:mockTestAzDevOpsOperationInvoked)
                                return !($script:mockTestAzDevOpsOperationInvoked)
                            }
                            Mock Test-AzDevOpsApiTimeoutExceeded { return $false }

                            It "Should invoke 'Test-AzDevOpsOperation' exactly twice - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                $script:mockTestAzDevOpsOperationInvoked = $false
                                Mock Test-AzDevOpsOperation {
                                    $script:mockTestAzDevOpsOperationInvoked = !($script:mockTestAzDevOpsOperationInvoked)
                                    return !($script:mockTestAzDevOpsOperationInvoked)
                                }

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                                Assert-MockCalled 'Test-AzDevOpsOperation' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Get-Date' exactly twice - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                                Assert-MockCalled 'Get-Date' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Start-Sleep' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                $script:mockTestAzDevOpsOperationInvoked = $false # for 'Test-AzDevOpsOperation' mock
                                Mock Start-Sleep {} -Verifiable

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                                Assert-MockCalled 'Start-Sleep' -Times 1 -Exactly -Scope It
                            }

                            It "Should invoke 'Test-AzDevOpsApiTimeoutExceeded' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                $script:mockTestAzDevOpsOperationInvoked = $false # for 'Test-AzDevOpsOperation' mock
                                Mock Test-AzDevOpsApiTimeoutExceeded { return $false } -Verifiable

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete

                                Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 1 -Exactly -Scope It
                            }

                        }
                    }


                    Context "When 'Test-AzDevOpsOperation' returns false, and exceeds timeout (i.e. 'Test-AzDevOpsApiTimeoutExceeded' returns true)" {
                        Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                        Mock Test-AzDevOpsApiTimeoutExceeded { return $true } # i.e. Timeout exceeded
                        Mock Test-AzDevOpsOperation { return $false } # i.e. Operation has not completed

                        It "Should throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete } | Should -Throw
                        }
                    }


                    Context "When also called with optional, 'WaitIntervalMilliseconds' parameter" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }


                    }


                    Context "When also called with optional, 'WaitTimeoutMilliseconds' parameter" {

                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }


                    Context "When also called with both optional, 'WaitIntervalMilliseconds' and 'WaitTimeoutMilliseconds' parameters" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds
                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete `
                                                     -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete `
                                                   -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete `
                                                   -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }


                }


                Context "When also called with mandatory, 'IsSuccessful', switch parameter" {
                    Mock Get-AzDevOpsApiWaitIntervalMs { return 250 }
                    Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 }
                    Mock Test-AzDevOpsOperation { return $true }

                    It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful } | Should -Not -Throw
                    }

                    It "Should output null/nothing - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        $output =  Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                        $output | Should -BeNullOrEmpty
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitIntervalMs' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                        Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                        Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 1 -Exactly -Scope It
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitTimeoutMs' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                        Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                        Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 1 -Exactly -Scope It
                    }


                    Context "When 'Test-AzDevOpsOperation' returns true" {

                        It "Should invoke 'Test-AzDevOpsOperation' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Test-AzDevOpsOperation { return $true } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                            Assert-MockCalled 'Test-AzDevOpsOperation' -Times 1 -Exactly -Scope It
                        }

                        It "Should invoke 'Get-Date' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                            Assert-MockCalled 'Get-Date' -Times 1 -Exactly -Scope It
                        }

                        It "Should not invoke 'Start-Sleep' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Start-Sleep {} -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                            Assert-MockCalled 'Start-Sleep' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Test-AzDevOpsApiTimeoutExceeded' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Test-AzDevOpsApiTimeoutExceeded {} -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                            Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 0 -Exactly -Scope It
                        }
                    }


                    Context "When 'Test-AzDevOpsOperation' returns false, then true" {


                        Context "When 'WaitTimeoutMilliseconds' has not been exceeded" {
                            Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                            Mock Test-AzDevOpsOperation {
                                $script:mockTestAzDevOpsOperationInvoked = !($script:mockTestAzDevOpsOperationInvoked)
                                return !($script:mockTestAzDevOpsOperationInvoked)
                            }
                            Mock Test-AzDevOpsApiTimeoutExceeded { return $false }

                            It "Should invoke 'Test-AzDevOpsOperation' exactly twice - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                $script:mockTestAzDevOpsOperationInvoked = $false
                                Mock Test-AzDevOpsOperation {
                                    $script:mockTestAzDevOpsOperationInvoked = !($script:mockTestAzDevOpsOperationInvoked)
                                    return !($script:mockTestAzDevOpsOperationInvoked)
                                }

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                                Assert-MockCalled 'Test-AzDevOpsOperation' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Get-Date' exactly twice - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                                Assert-MockCalled 'Get-Date' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Start-Sleep' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                $script:mockTestAzDevOpsOperationInvoked = $false # for 'Test-AzDevOpsOperation' mock
                                Mock Start-Sleep {} -Verifiable

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                                Assert-MockCalled 'Start-Sleep' -Times 1 -Exactly -Scope It
                            }

                            It "Should invoke 'Test-AzDevOpsApiTimeoutExceeded' exactly once - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                                $script:mockTestAzDevOpsOperationInvoked = $false # for 'Test-AzDevOpsOperation' mock
                                Mock Test-AzDevOpsApiTimeoutExceeded { return $false } -Verifiable

                                Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful

                                Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 1 -Exactly -Scope It
                            }

                        }
                    }


                    Context "When 'Test-AzDevOpsOperation' returns false, and exceeds timeout (i.e. 'Test-AzDevOpsApiTimeoutExceeded' returns true)" {
                        Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                        Mock Test-AzDevOpsApiTimeoutExceeded { return $true } # i.e. Timeout exceeded
                        Mock Test-AzDevOpsOperation { return $false } # i.e. Operation has not completed

                        It "Should throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful } | Should -Throw
                        }
                    }


                    Context "When also called with optional, 'WaitIntervalMilliseconds' parameter" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }


                    }


                    Context "When also called with optional, 'WaitTimeoutMilliseconds' parameter" {

                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }


                    Context "When also called with both optional, 'WaitIntervalMilliseconds' and 'WaitTimeoutMilliseconds' parameters" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds
                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful `
                                                     -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful `
                                                   -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsSuccessful `
                                                   -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }

                }


                Context "When also called with both mandatory, 'IsComplete' and 'IsSuccessful', switch parameters" {

                    It "Should throw - '<ApiUri>', '<Pat>', '<OperationId>'" -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$OperationId )

                        { Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId -IsComplete -IsSuccessful } | Should -Throw
                    }
                }
            }
        }


        Context "When input parameters are invalid" {

            # TODO

        }
    }
}
