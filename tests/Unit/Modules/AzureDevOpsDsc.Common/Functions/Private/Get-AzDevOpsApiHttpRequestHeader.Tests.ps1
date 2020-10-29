
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {
    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiHttpRequestHeader' -Tag 'GetAzDevOpsApiHttpRequestHeader' {

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called with valid "Pat" parameter' {

                $testCasesValidPats = @(
                    @{
                        Pat = '1234567890123456789012345678901234567890123456789012' },
                    @{
                        Pat = '0987654321098765432109876543210987654321098765432109' },
                    @{
                        Pat = '0913uhuh3wedwndfwsni2242msfwneu254uhufs009oosfmikm34' }
                )

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

                $testCasesInvalidPats = @(
                    @{
                        Pat = $null },
                    @{
                        Pat = '' }
                    @{
                        Pat = ' ' },
                    @{
                        Pat = 'a 1' },
                    @{
                        Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm3' },
                    @{
                        Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm34x' }
                )

                It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                    param ([string]$Pat)

                    { Get-AzDevOpsApiHttpRequestHeader -Pat $Pat } | Should -Throw

                }
            }
        }

    }

}
