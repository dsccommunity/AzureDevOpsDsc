
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {
    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsServicesApiUri' -Tag 'GetAzDevOpsServicesApiUri' {

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called with valid "Organisation" parameter' {

                $testCasesValidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Valid'

                It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    { Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName } | Should -Not -Throw
                }

                It 'Should return "https://dev.azure.com/<OrganizationName>/_apis/" - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    $result = Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName
                    $result | Should -Be "https://dev.azure.com/$OrganizationName/_apis/"
                }

                It 'Should return $("Get-AzDevOpsServicesUri"+"_apis/") - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    $result = Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName
                    $result | Should -Be $($(Get-AzDevOpsServicesUri -OrganizationName $OrganizationName) + '_apis/')
                }

                It 'Should return URI in lowercase' {
                    $OrganizationName = 'UPPERcasedORGANIZATIONname'

                    $result = Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName
                    $result | Should -BeExactly $(Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName).ToLower()
                }

            }



        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called with invalid "OrganizationName" parameter' {

                $testCasesInvalidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Invalid'

                It "Should throw - '<OrganizationName>'" -TestCases $testCasesInvalidOrganizationNames {
                    param ([string]$OrganizationName)

                    { Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName } | Should -Throw

                }
            }
        }

    }

}
