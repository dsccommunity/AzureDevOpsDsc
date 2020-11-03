
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiUriResourceName' -Tag 'GetAzDevOpsApiUriResourceName' {

        Context 'When called with valid parameters' {

            Context 'When called without "-ResourceName" parameter' {

                BeforeAll {

                    $testCasesValidApiUriResourceName = Get-TestCase -ScopeName 'ApiUriResourceName' -TestCaseName 'Valid'
                }

                It 'Should not throw' {
                    param ()

                    { Get-AzDevOpsApiUriResourceName } | Should -Not -Throw
                }

                It 'Should return "object[]" or "string"' {
                    param ()

                    $result = Get-AzDevOpsApiUriResourceName
                    $result.GetType() | Should -BeIn @(@('ApiUriResourceName1','ApiUriResourceName2').GetType(),'ApiUriResourceName1'.GetType())
                }

                It 'Should return all resources that are present in $testCasesValidApiUriResourceName variable'{
                    param ()

                    [string[]]$result = Get-AzDevOpsApiUriResourceName
                    $result.Count | Should -Be $($testCasesValidApiUriResourceName.Count)
                }
            }

            Context 'When called with valid "-ResourceName" parameter' {

                $testCasesValidResourceName = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'

                BeforeAll {
                }

                It 'Should not throw - "<ResourceName>"' -TestCases $testCasesValidResourceName {
                    param ([string]$ResourceName)
                    Write-Verbose $ResourceName

                    { Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName} | Should -Not -Throw
                }

                It 'Should return "string" - "<ResourceName>"' -TestCases $testCasesValidResourceName {
                    param ([string]$ResourceName)

                    [string]$result = Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName
                    $result.GetType() | Should -Be @('ApiUriResourceName1'.GetType())
                }

            }

            Context 'When called with invalid "-ResourceName" parameter' {

                $testCasesInvalidResourceName = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'

                BeforeAll {
                }

                It 'Should throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceName {
                    param ([string]$ResourceName)
                    Write-Verbose $ResourceName

                    { Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName} | Should -Throw
                }

            }

        }

    }

}
