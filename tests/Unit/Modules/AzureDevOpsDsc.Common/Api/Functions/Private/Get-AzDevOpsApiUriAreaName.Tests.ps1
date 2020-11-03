
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiUriAreaName' -Tag 'GetAzDevOpsApiUriAreaName' {

        Context 'When called with valid parameters' {

            Context 'When called without "-ResourceName" parameter' {

                BeforeAll {

                    $testCasesValidApiUriAreaName = Get-TestCase -ScopeName 'ApiUriAreaName' -TestCaseName 'Valid'
                }

                It 'Should not throw' {
                    param ()

                    { Get-AzDevOpsApiUriAreaName } | Should -Not -Throw
                }

                It 'Should return "object[]" or "string"' {
                    param ()

                    $result = Get-AzDevOpsApiUriAreaName
                    $result.GetType() | Should -BeIn @(@('ApiUriAreaName1','ApiUriAreaName2').GetType(),'ApiUriAreaName1'.GetType())
                }

                It 'Should return all resources that are present in $testCasesValidApiUriAreaName variable'{
                    param ()

                    [string[]]$result = Get-AzDevOpsApiUriAreaName
                    $result.Count | Should -Be $($testCasesValidApiUriAreaName.Count)
                }
            }

            Context 'When called with valid "-ResourceName" parameter' {

                $testCasesValidResourceName = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'

                BeforeAll {
                }

                It 'Should not throw - "<ResourceName>"' -TestCases $testCasesValidResourceName {
                    param ([string]$ResourceName)
                    Write-Verbose $ResourceName

                    { Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName} | Should -Not -Throw
                }

                It 'Should return "string" - "<ResourceName>"' -TestCases $testCasesValidResourceName {
                    param ([string]$ResourceName)

                    [string]$result = Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName
                    $result.GetType() | Should -Be @('ApiUriAreaName1'.GetType())
                }

            }

            Context 'When called with invalid "-ResourceName" parameter' {

                $testCasesInvalidResourceName = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'

                BeforeAll {
                }

                It 'Should throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceName {
                    param ([string]$ResourceName)
                    Write-Verbose $ResourceName

                    { Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName} | Should -Throw
                }

            }

        }

    }

}
