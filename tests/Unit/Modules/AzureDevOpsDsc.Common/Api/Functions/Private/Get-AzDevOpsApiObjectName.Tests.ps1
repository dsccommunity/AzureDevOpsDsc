
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiResourceName' -Tag 'GetAzDevOpsApiResourceName' {

        Context 'When called with valid parameters' {


            BeforeAll {

                $testCasesValidResourceName = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
            }

            It 'Should not throw' {
                param ()

                { Get-AzDevOpsApiResourceName } | Should -Not -Throw
            }

            It 'Should return "object[]"' {
                param ()

                $result = Get-AzDevOpsApiResourceName
                $result.GetType() | Should -Be @('ResourceName1','ResourceName2').GetType()
            }

            It 'Should return all resources that are present in $testCasesValidResourceName variable'{
                param ()

                $result = Get-AzDevOpsApiResourceName
                $result.Count | Should -Be $($testCasesValidResourceName.Count)
            }

        }

    }

}
