
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsPat' -Tag 'TestAzDevOpsPat' {

        $testCasesValidPats = @(
            @{
                Pat = '1234567890123456789012345678901234567890123456789012' },
            @{
                Pat = '0987654321098765432109876543210987654321098765432109' },
            @{
                Pat = '0913uhuh3wedwndfwsni2242msfwneu254uhufs009oosfmikm34' }
        )

        $testCasesEmptyPats = @(
            @{
                Pat = $null },
            @{
                Pat = '' }
        )

        $testCasesInvalidPats = @(
            @{
                Pat = ' ' },
            @{
                Pat = 'a 1' },
            @{
                Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm3' },
            @{
                Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm34x' }
        )

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "Pat" parameter' {

                    It 'Should not throw - "<Pat>"' -TestCases $testCasesValidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<Pat>"' -TestCases $testCasesValidPats {
                        param ([string]$Pat)

                        $result = Test-AzDevOpsPat -Pat $Pat -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "Pat" parameter' {

                    It 'Should throw - "<Pat>"' -TestCases $testCasesEmptyPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<Pat>"' -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<Pat>"' -TestCases $testCasesInvalidPats {
                        param ([string]$OrganizationName)

                        $result = Test-AzDevOpsPat -Pat $Pat -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "Pat" parameter' {

                    It 'Should throw - "<Pat>"' -TestCases $testCasesValidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "Pat" parameter' {

                    It 'Should throw - "<Pat>"' -TestCases $testCasesEmptyPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<Pat>"' -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
