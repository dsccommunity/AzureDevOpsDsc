
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {
    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsServicesUri' -Tag 'GetAzDevOpsServicesUri' {

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called with valid "Organisation" parameter' {

                $testCasesValidOrganizationNames = @(
                    @{
                        OrganizationName = 'Organisation1' },
                    @{
                        OrganizationName = 'Organisation-2' },
                    @{
                        OrganizationName = 'Organisation_3' }
                )

                It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    { Get-AzDevOpsServicesUri -OrganizationName $OrganizationName } | Should -Not -Throw
                }

                It 'Should return "https://dev.azure.com/<OrganizationName>/" - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    $result = Get-AzDevOpsServicesUri -OrganizationName $OrganizationName
                    $result | Should -Be "https://dev.azure.com/$OrganizationName/"
                }
            }


        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called with invalid "OrganizationName" parameter' {

                $testCasesInvalidOrganizationNames = @(
                    @{
                        OrganizationName = $null },
                    @{
                        OrganizationName = '' },
                    @{
                        OrganizationName = ' ' },
                    @{
                        OrganizationName = '%' },
                    @{
                        OrganizationName = 'Organization 0' }
                )

                It "Should throw - '<OrganizationName>'" -TestCases $testCasesInvalidOrganizationNames {
                    param ([string]$OrganizationName)

                    { Get-AzDevOpsServicesUri -OrganizationName $OrganizationName } | Should -Throw

                }
            }
        }

    }

}
