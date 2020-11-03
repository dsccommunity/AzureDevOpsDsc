
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiVersion' -Tag 'GetAzDevOpsApiVersion' {

        Context 'When called with valid parameters' {

            Context 'When called without "-Default" switch' {

                BeforeAll {

                    $testCasesValidApiVersion = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Valid'
                }

                It 'Should not throw' {
                    param ()

                    { Get-AzDevOpsApiVersion } | Should -Not -Throw
                }

                It 'Should return "object[]" or "string"' {
                    param ()

                    $result = Get-AzDevOpsApiVersion
                    $result.GetType() | Should -BeIn @(@('ApiVersion1','ApiVersion2').GetType(),'ApiVersion1'.GetType())
                }

                It 'Should return all objects that are present in $testCasesValidApiVersion variable'{
                    param ()

                    [string[]]$result = Get-AzDevOpsApiVersion
                    $result.Count | Should -Be $($testCasesValidApiVersion.Count)
                }
            }

            Context 'When called with "-Default" switch' {

                BeforeAll {
                    $defaultApiVersion = '6.0' # Note: This will need changing if the API version supported is updated
                    $testCasesValidApiVersion = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Valid'
                }

                It 'Should not throw' {
                    param ()

                    { Get-AzDevOpsApiVersion -Default } | Should -Not -Throw
                }

                It 'Should return "string"' {
                    param ()

                    [string]$result = Get-AzDevOpsApiVersion -Default
                    $result.GetType() | Should -Be @('ApiVersion1'.GetType())
                }

                It "Should return the 'default' version ($defaultApiVersion)"{
                    param ()

                    [string]$result = Get-AzDevOpsApiVersion -Default
                    $result | Should -Be $defaultApiVersion
                }
            }

        }

    }

}
