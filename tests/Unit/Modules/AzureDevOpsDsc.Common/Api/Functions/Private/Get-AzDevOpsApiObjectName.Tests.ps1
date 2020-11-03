
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiObjectName' -Tag 'GetAzDevOpsApiObjectName' {

        Context 'When called with valid parameters' {


            BeforeAll {

                $testCasesValidObjectName = Get-TestCase -ScopeName 'ObjectName' -TestCaseName 'Valid'
            }

            It 'Should not throw' {
                param ()

                { Get-AzDevOpsApiObjectName } | Should -Not -Throw
            }

            It 'Should return "object[]"' {
                param ()

                $result = Get-AzDevOpsApiObjectName
                $result.GetType() | Should -Be @('ObjectName1','ObjectName2').GetType()
            }

            It 'Should return all objects that are present in $testCasesValidObjectName variable'{
                param ()

                $result = Get-AzDevOpsApiObjectName
                $result.Count | Should -Be $($testCasesValidObjectName.Count)
            }

        }

    }

}
