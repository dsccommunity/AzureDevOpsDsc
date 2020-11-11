
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidHttpRequestHeaders = Get-TestCase -ScopeName 'HttpRequestHeader' -TestCaseName 'Valid'
        $testCasesInvalidHttpRequestHeaders = Get-TestCase -ScopeName 'HttpRequestHeader' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with "HttpRequestHeader" parameter value and the "IsValid" switch' {


                Context 'When "HttpRequestHeader" parameter value is a valid "HttpRequestHeader"' {

                    It 'Should not throw - "<HttpRequestHeader>"' -TestCases $testCasesValidHttpRequestHeaders {
                        param ([Hashtable]$HttpRequestHeader)

                        { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $HttpRequestHeader -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true' -TestCases $testCasesValidHttpRequestHeaders {
                        param ([Hashtable]$HttpRequestHeader)

                        Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $HttpRequestHeader -IsValid | Should -BeTrue
                    }
                }


                Context 'When "HttpRequestHeader" parameter value is an invalid "HttpRequestHeader"' {

                    It 'Should not throw - "<HttpRequestHeader>"' -TestCases $testCasesInvalidHttpRequestHeaders {
                        param ([Hashtable]$HttpRequestHeader)

                        { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $HttpRequestHeader -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false' -TestCases $testCasesInvalidHttpRequestHeaders {
                        param ([Hashtable]$HttpRequestHeader)

                        Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $HttpRequestHeader -IsValid | Should -BeFalse
                    }
                }
            }
        }


        Context "When input parameters are invalid" {


            Context 'When called with no/null parameter values/switches' {

                It 'Should throw' {
                    param ([Hashtable]$HttpRequestHeader)

                    { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader:$null } | Should -Throw
                }
            }


            Context 'When "HttpRequestHeader" parameter value is a valid "HttpRequestHeader"' {


                Context 'When called with "HttpRequestHeader" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<HttpRequestHeader>"' -TestCases $testCasesValidHttpRequestHeaders {
                        param ([Hashtable]$HttpRequestHeader)

                        { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $HttpRequestHeader -IsValid:$false } | Should -Throw
                    }
                }
            }


            Context 'When "HttpRequestHeader" parameter value is an invalid "HttpRequestHeader"' {


                Context 'When called with "HttpRequestHeader" parameter value but a $false "IsValid" switch value' {

                    It 'Should throw - "<HttpRequestHeader>"' -TestCases $testCasesInvalidHttpRequestHeaders {
                        param ([Hashtable]$HttpRequestHeader)

                        { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $HttpRequestHeader -IsValid:$false } | Should -Throw
                    }
                }
            }


        }
    }
}
