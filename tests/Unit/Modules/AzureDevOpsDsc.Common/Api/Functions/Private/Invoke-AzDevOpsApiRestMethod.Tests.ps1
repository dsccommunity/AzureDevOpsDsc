
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
        $defaultHttpContentType = 'application/json'
        $defaultHttpBody = ''
        $defaultRetryAttempts = 5
        $defaultRetryIntervalMs = 250

        # Mock functions called in function
        Mock Invoke-RestMethod {}
        # Mock New-InvalidOperationException {} # Do not mock
        Mock Start-Sleep {}

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidHttpMethods = Get-TestCase -ScopeName 'HttpMethod' -TestCaseName 'Valid'
        $testCasesValidHttpRequestHeaders = Get-TestCase -ScopeName 'HttpRequestHeader' -TestCaseName 'Valid'
        $testCasesValidApiUriHttpMethodHttpRequestHeaders = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidHttpMethods,
            $testCasesValidHttpRequestHeaders) -Expand
        $testCasesValidApiUriHttpMethodHttpRequestHeaders3 = $testCasesValidApiUriHttpMethodHttpRequestHeaders | Select-Object -First 3

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidHttpMethods = Get-TestCase -ScopeName 'HttpMethod' -TestCaseName 'Invalid'
        $testCasesInvalidHttpRequestHeaders = Get-TestCase -ScopeName 'HttpRequestHeader' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriHttpMethodHttpRequestHeaders = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidHttpMethods,
            $testCasesInvalidHttpRequestHeaders) -Expand
        $testCasesInvalidApiUriHttpMethodHttpRequestHeaders3 = $testCasesInvalidApiUriHttpMethodHttpRequestHeaders | Select-Object -First 3


        Context 'When input parameters are valid' {

            Context 'When called just with mandatory, "ApiUri", "HttpMethod" and "HttpRequestHeader" parameters' {

                It 'Should not throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader } | Should -Not -Throw
                }

                It 'Should output nothing/null - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    $output = Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                    $output | Should -BeNullOrEmpty
                }

                It 'Should invoke "Invoke-RestMethod" exactly once - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    Mock Invoke-RestMethod {} -Verifiable

                    Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                    Assert-MockCalled Invoke-RestMethod -Times 1 -Exactly -Scope 'It'
                }

                Context 'When "Invoke-RestMethod" throws an exception on every retry' {
                    Mock Invoke-RestMethod { throw "Some exception" }

                    It 'Should invoke "Invoke-RestMethod" number of times equal to "RetryAttempts" parameter value + 1 - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                        param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                        Mock Invoke-RestMethod { throw "Some exception" } -Verifiable
                        Mock New-InvalidOperationException {}

                        Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                        Assert-MockCalled Invoke-RestMethod -Times $($defaultRetryAttempts+1) -Exactly -Scope 'It'
                    }


                    It 'Should invoke "Start-Sleep" number of times equal to "RetryAttempts" parameter value + 1 - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                        param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                        Mock Start-Sleep { } -Verifiable

                        Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                        Assert-MockCalled Start-Sleep -Times $($defaultRetryAttempts+1) -Exactly -Scope 'It'
                    }


                    It 'Should invoke "New-InvalidOperationException" exactly once - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders {
                        param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                        Mock New-InvalidOperationException {} -Verifiable

                        Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                        Assert-MockCalled New-InvalidOperationException -Times 1 -Exactly -Scope 'It'
                    }

                }

            }
        }


        Context 'When input parameters are invalid' {

            Context 'When called without mandatory, "ApiUri" parameter' {

                It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader } | Should -Throw
                }

            }

            Context 'When called without mandatory, "HttpMethod" parameter' {

                It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $null -HttpRequestHeader $HttpRequestHeader } | Should -Throw
                }

            }

            Context 'When called without mandatory, "ApiUri" and "HttpMethod" parameters' {

                It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $null -HttpRequestHeader $HttpRequestHeader } | Should -Throw
                }

            }

            Context 'When called without mandatory, "HttpRequestHeader" parameter' {

                It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $null } | Should -Throw
                }

            }

            Context 'When called without mandatory, "ApiUri" and "HttpRequestHeader" parameters' {

                It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $HttpMethod -HttpRequestHeader $null } | Should -Throw
                }

            }

            Context 'When called without mandatory, "HttpMethod" and "HttpRequestHeader" parameters' {

                It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $null -HttpRequestHeader $null } | Should -Throw
                }

            }

            Context 'When called without mandatory, "ApiUri", "HttpMethod" and "HttpRequestHeader" parameters' {

                It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $null -HttpRequestHeader $null } | Should -Throw
                }

            }
        }
    }
}
# Existing code...

Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

    # Existing code...

    Context 'When input parameters are valid' {

        # Existing code...

        Context 'When called just with mandatory, "ApiUri", "HttpMethod" and "HttpRequestHeader" parameters' {

            # Existing code...

            It 'Should not throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader } | Should -Not -Throw
            }

            It 'Should output nothing/null - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                $output = Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                $output | Should -BeNullOrEmpty
            }

            It 'Should invoke "Invoke-RestMethod" exactly once - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                Mock Invoke-RestMethod {} -Verifiable

                Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                Assert-MockCalled Invoke-RestMethod -Times 1 -Exactly -Scope 'It'
            }

            Context 'When "Invoke-RestMethod" throws an exception on every retry' {
                Mock Invoke-RestMethod { throw "Some exception" }

                It 'Should invoke "Invoke-RestMethod" number of times equal to "RetryAttempts" parameter value + 1 - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    Mock Invoke-RestMethod { throw "Some exception" } -Verifiable
                    Mock New-InvalidOperationException {}

                    Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                    Assert-MockCalled Invoke-RestMethod -Times $($defaultRetryAttempts+1) -Exactly -Scope 'It'
                }


                It 'Should invoke "Start-Sleep" number of times equal to "RetryAttempts" parameter value + 1 - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    Mock Start-Sleep { } -Verifiable

                    Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                    Assert-MockCalled Start-Sleep -Times $($defaultRetryAttempts+1) -Exactly -Scope 'It'
                }


                It 'Should invoke "New-InvalidOperationException" exactly once - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders {
                    param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                    Mock New-InvalidOperationException {} -Verifiable

                    Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader

                    Assert-MockCalled New-InvalidOperationException -Times 1 -Exactly -Scope 'It'
                }

            }

        }
    }


    Context 'When input parameters are invalid' {

        # Existing code...

        Context 'When called without mandatory, "ApiUri" parameter' {

            It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $HttpMethod -HttpRequestHeader $HttpRequestHeader } | Should -Throw
            }

        }

        Context 'When called without mandatory, "HttpMethod" parameter' {

            It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $null -HttpRequestHeader $HttpRequestHeader } | Should -Throw
            }

        }

        Context 'When called without mandatory, "ApiUri" and "HttpMethod" parameters' {

            It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $null -HttpRequestHeader $HttpRequestHeader } | Should -Throw
            }

        }

        Context 'When called without mandatory, "HttpRequestHeader" parameter' {

            It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $null } | Should -Throw
            }

        }

        Context 'When called without mandatory, "ApiUri" and "HttpRequestHeader" parameters' {

            It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $HttpMethod -HttpRequestHeader $null } | Should -Throw
            }

        }

        Context 'When called without mandatory, "HttpMethod" and "HttpRequestHeader" parameters' {

            It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $null -HttpRequestHeader $null } | Should -Throw
            }

        }

        Context 'When called without mandatory, "ApiUri", "HttpMethod" and "HttpRequestHeader" parameters' {

            It 'Should throw - "<ApiUri>", "<HttpMethod>", "<HttpRequestHeader>"' -TestCases $testCasesValidApiUriHttpMethodHttpRequestHeaders3 {
                param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

                { Invoke-AzDevOpsApiRestMethod -ApiUri $null -HttpMethod $null -HttpRequestHeader $null } | Should -Throw
            }

        }
    }
}
