
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

        # Get default, parameter values
        $defaultWaitIntervalMilliseconds = Get-AzDevOpsApiWaitIntervalMs
        $defaultWaitTimeoutMilliseconds = Get-AzDevOpsApiWaitTimeoutMs

        # Mock functions called in function
        Mock Get-AzDevOpsApiWaitIntervalMs {}
        Mock Get-AzDevOpsApiWaitTimeoutMs {}
        # Mock Get-Date {} # Do not mock
        # Mock New-InvalidOperationException {} # Do not mock
        Mock Start-Sleep {}
        Mock Test-AzDevOpsApiResource {}
        Mock Test-AzDevOpsApiTimeoutExceeded {}

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Valid'
        $testCasesValidApiUriPatResourceIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidResourceIds) -Expand
        $testCasesValidApiUriPatResourceIds3 = $testCasesValidApiUriPatResourceIds | Select-Object -First 3

        $validApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Valid'

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatResourceIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidResourceIds) -Expand
        $testCasesInvalidApiUriPatResourceIds3 = $testCasesInvalidApiUriPatResourceIds | Select-Object -First 3

        $invalidApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context "When called with all, mandatory parameters ('ApiUri', 'Pat' and 'ResourceId')" {

                It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                    param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                    { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceId $ResourceId } | Should -Throw
                }


                Context "When also called with mandatory, 'IsPresent', switch parameter" {
                    Mock Get-AzDevOpsApiWaitIntervalMs { return 250 }
                    Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 }
                    Mock Test-AzDevOpsApiResource { return $true }

                    It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent } | Should -Not -Throw
                    }

                    It "Should output null/nothing - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        $output =  Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                        $output | Should -BeNullOrEmpty
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitIntervalMs' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                        Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                        Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 1 -Exactly -Scope It
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitTimeoutMs' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                        Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                        Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 1 -Exactly -Scope It
                    }

                    Context "When also called with valid 'ApiVersion' parameter value" {

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $validApiVersion -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent } | Should -Not -Throw
                        }
                    }

                    Context "When also called with invalid 'ApiVersion' parameter value" {

                        It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $invalidApiVersion -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent } | Should -Throw
                        }
                    }

                    Context "When 'Test-AzDevOpsApiResource' returns true" {

                        It "Should invoke 'Test-AzDevOpsApiResource' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Test-AzDevOpsApiResource { return $true } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                            Assert-MockCalled 'Test-AzDevOpsApiResource' -Times 1 -Exactly -Scope It
                        }

                        It "Should invoke 'Get-Date' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                            Assert-MockCalled 'Get-Date' -Times 1 -Exactly -Scope It
                        }

                        It "Should not invoke 'Start-Sleep' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Start-Sleep {} -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                            Assert-MockCalled 'Start-Sleep' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Test-AzDevOpsApiTimeoutExceeded' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Test-AzDevOpsApiTimeoutExceeded {} -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                            Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 0 -Exactly -Scope It
                        }
                    }


                    Context "When 'Test-AzDevOpsApiResource' returns false, then true" {


                        Context "When 'WaitTimeoutMilliseconds' has not been exceeded" {
                            Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                            Mock Test-AzDevOpsApiResource {
                                $script:mockTestAzDevOpsApiResourceInvoked = !($script:mockTestAzDevOpsApiResourceInvoked)
                                return !($script:mockTestAzDevOpsApiResourceInvoked)
                            }
                            Mock Test-AzDevOpsApiTimeoutExceeded { return $false }

                            It "Should invoke 'Test-AzDevOpsApiResource' exactly twice - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                $script:mockTestAzDevOpsApiResourceInvoked = $false
                                Mock Test-AzDevOpsApiResource {
                                    $script:mockTestAzDevOpsApiResourceInvoked = !($script:mockTestAzDevOpsApiResourceInvoked)
                                    return !($script:mockTestAzDevOpsApiResourceInvoked)
                                }

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                                Assert-MockCalled 'Test-AzDevOpsApiResource' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Get-Date' exactly twice - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                                Assert-MockCalled 'Get-Date' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Start-Sleep' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                $script:mockTestAzDevOpsApiResourceInvoked = $false # for 'Test-AzDevOpsApiResource' mock
                                Mock Start-Sleep {} -Verifiable

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                                Assert-MockCalled 'Start-Sleep' -Times 1 -Exactly -Scope It
                            }

                            It "Should invoke 'Test-AzDevOpsApiTimeoutExceeded' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                $script:mockTestAzDevOpsApiResourceInvoked = $false # for 'Test-AzDevOpsApiResource' mock
                                Mock Test-AzDevOpsApiTimeoutExceeded { return $false } -Verifiable

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent

                                Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 1 -Exactly -Scope It
                            }

                        }
                    }


                    Context "When 'Test-AzDevOpsApiResource' returns false, and exceeds timeout (i.e. 'Test-AzDevOpsApiTimeoutExceeded' returns true)" {
                        Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                        Mock Test-AzDevOpsApiTimeoutExceeded { return $true } # i.e. Timeout exceeded
                        Mock Test-AzDevOpsApiResource { return $false } # i.e. ApiResource has not completed

                        It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent } | Should -Throw
                        }
                    }


                    Context "When also called with optional, 'WaitIntervalMilliseconds' parameter" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }


                    }


                    Context "When also called with optional, 'WaitTimeoutMilliseconds' parameter" {

                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }


                    Context "When also called with both optional, 'WaitIntervalMilliseconds' and 'WaitTimeoutMilliseconds' parameters" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds
                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent `
                                                     -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent `
                                                   -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent `
                                                   -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }


                }


                Context "When also called with mandatory, 'IsAbsent', switch parameter" {
                    Mock Get-AzDevOpsApiWaitIntervalMs { return 250 }
                    Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 }
                    Mock Test-AzDevOpsApiResource { return $false }

                    It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent } | Should -Not -Throw
                    }

                    It "Should output null/nothing - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        $output =  Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                        $output | Should -BeNullOrEmpty
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitIntervalMs' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                        Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                        Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 1 -Exactly -Scope It
                    }

                    It "Should invoke 'Get-AzDevOpsApiWaitTimeoutMs' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                        Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                        Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 1 -Exactly -Scope It
                    }


                    Context "When also called with valid 'ApiVersion' parameter value" {

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $validApiVersion -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent } | Should -Not -Throw
                        }
                    }


                    Context "When also called with invalid 'ApiVersion' parameter value" {

                        It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $invalidApiVersion -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent } | Should -Throw
                        }
                    }


                    Context "When 'Test-AzDevOpsApiResource' returns false" {

                        It "Should invoke 'Test-AzDevOpsApiResource' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Test-AzDevOpsApiResource { return $false } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                            Assert-MockCalled 'Test-AzDevOpsApiResource' -Times 1 -Exactly -Scope It
                        }

                        It "Should invoke 'Get-Date' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                            Assert-MockCalled 'Get-Date' -Times 1 -Exactly -Scope It
                        }

                        It "Should not invoke 'Start-Sleep' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Start-Sleep {} -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                            Assert-MockCalled 'Start-Sleep' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Test-AzDevOpsApiTimeoutExceeded' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Test-AzDevOpsApiTimeoutExceeded {} -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                            Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 0 -Exactly -Scope It
                        }
                    }


                    Context "When 'Test-AzDevOpsApiResource' returns true, then false" {


                        Context "When 'WaitTimeoutMilliseconds' has not been exceeded" {
                            Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                            Mock Test-AzDevOpsApiResource {
                                $script:mockTestAzDevOpsApiResourceInvoked = !($script:mockTestAzDevOpsApiResourceInvoked)
                                return $script:mockTestAzDevOpsApiResourceInvoked
                            }
                            Mock Test-AzDevOpsApiTimeoutExceeded { return $false }

                            It "Should invoke 'Test-AzDevOpsApiResource' exactly twice - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                $script:mockTestAzDevOpsApiResourceInvoked = $false
                                Mock Test-AzDevOpsApiResource {
                                    $script:mockTestAzDevOpsApiResourceInvoked = !($script:mockTestAzDevOpsApiResourceInvoked)
                                    return $script:mockTestAzDevOpsApiResourceInvoked
                                }

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                                Assert-MockCalled 'Test-AzDevOpsApiResource' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Get-Date' exactly twice - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                Mock Get-Date { return [DateTime]::get_UtcNow() } -Verifiable

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                                Assert-MockCalled 'Get-Date' -Times 2 -Exactly -Scope It
                            }

                            It "Should invoke 'Start-Sleep' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                $script:mockTestAzDevOpsApiResourceInvoked = $false # for 'Test-AzDevOpsApiResource' mock
                                Mock Start-Sleep {} -Verifiable

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                                Assert-MockCalled 'Start-Sleep' -Times 1 -Exactly -Scope It
                            }

                            It "Should invoke 'Test-AzDevOpsApiTimeoutExceeded' exactly once - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                                param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                                $script:mockTestAzDevOpsApiResourceInvoked = $false # for 'Test-AzDevOpsApiResource' mock
                                Mock Test-AzDevOpsApiTimeoutExceeded { return $false } -Verifiable

                                Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent

                                Assert-MockCalled 'Test-AzDevOpsApiTimeoutExceeded' -Times 1 -Exactly -Scope It
                            }

                        }
                    }


                    Context "When 'Test-AzDevOpsApiResource' returns false, and exceeds timeout (i.e. 'Test-AzDevOpsApiTimeoutExceeded' returns true)" {
                        Mock Get-AzDevOpsApiWaitTimeoutMs {250} # 250ms
                        Mock Test-AzDevOpsApiTimeoutExceeded { return $true } # i.e. Timeout exceeded
                        Mock Test-AzDevOpsApiResource { return $true } # i.e. ApiResource has not completed

                        It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent } | Should -Throw
                        }
                    }


                    Context "When also called with optional, 'WaitIntervalMilliseconds' parameter" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }


                    }


                    Context "When also called with optional, 'WaitTimeoutMilliseconds' parameter" {

                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }


                    Context "When also called with both optional, 'WaitIntervalMilliseconds' and 'WaitTimeoutMilliseconds' parameters" {

                        $exampleWaitIntervalMilliseconds = $defaultWaitIntervalMilliseconds
                        $exampleWaitTimeoutMilliseconds = $defaultWaitTimeoutMilliseconds

                        It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent `
                                                       -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds } | Should -Not -Throw
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitIntervalMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitIntervalMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent `
                                                     -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitIntervalMs' -Times 0 -Exactly -Scope It
                        }

                        It "Should not invoke 'Get-AzDevOpsApiWaitTimeoutMs' - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                            param( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                            Mock Get-AzDevOpsApiWaitTimeoutMs { return 250 } -Verifiable

                            Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsAbsent `
                                                     -WaitTimeoutMilliseconds $exampleWaitTimeoutMilliseconds -WaitIntervalMilliseconds $exampleWaitIntervalMilliseconds

                            Assert-MockCalled 'Get-AzDevOpsApiWaitTimeoutMs' -Times 0 -Exactly -Scope It
                        }

                    }

                }


                Context "When also called with both mandatory, 'IsPresent' and 'IsAbsent', switch parameters" {

                    It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceIds3 {
                        param ( [System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceId )

                        { Wait-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project' -ResourceId $ResourceId -IsPresent -IsAbsent } | Should -Throw
                    }
                }
            }
        }


        Context "When input parameters are invalid" {

            # TODO

        }
    }
}
