# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {

    Describe 'Update-AzManagedIdentity' {

        Context 'When OrganizationName is set' {

            It 'Should update the global variable DSCAZDO_ManagedIdentityToken' {
                $organizationName = 'MyOrganization'
                $global:DSCAZDO_OrganizationName = $organizationName

                Update-AzManagedIdentity

                $Global:DSCAZDO_AuthenticationToken | Should -Not -Be $null
            }
        }

        Context 'When OrganizationName is not set' {

            It 'Should throw an error' {
                { Update-AzManagedIdentity } | Should -Throw
            }
        }
    }

}
