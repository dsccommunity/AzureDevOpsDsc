
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {
    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiHttpRequestHeader' -Tag 'GetAzDevOpsApiHttpRequestHeader' {

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called with valid "Pat" parameter' {

                $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'

                It 'Should not throw - "<Pat>"' -TestCases $testCasesValidPats {
                    param ([string]$Pat)

                    { Get-AzDevOpsApiHttpRequestHeader -Pat $Pat } | Should -Not -Throw
                }

                It 'Should return "hashtable" - "<Pat>"' -TestCases $testCasesValidPats {
                    param ([string]$Pat)

                    $result = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat
                    $result.GetType() | Should -Be $($([hashtable]::new()).GetType())
                }

                It 'Should return correct "Authorization" hashtable property value - "<Pat>"' -TestCases $testCasesValidPats {
                    param ([string]$Pat)

                    $result = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat
                    $result.Authorization | Should -Be $('Basic ' +
                        [Convert]::ToBase64String(
                        [Text.Encoding]::ASCII.GetBytes(":$Pat")))
                }

            }



        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called with invalid "Pat" parameter' {

                $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'

                It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                    param ([string]$Pat)

                    { Get-AzDevOpsApiHttpRequestHeader -Pat $Pat } | Should -Throw

                }
            }

            Context 'When called with empty "Pat" parameter' {

                $testCasesEmptyPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Empty'

                It "Should throw - '<Pat>'" -TestCases $testCasesEmptyPats {
                    param ([string]$Pat)

                    { Get-AzDevOpsApiHttpRequestHeader -Pat $Pat } | Should -Throw

                }
            }
        }

    }

}
