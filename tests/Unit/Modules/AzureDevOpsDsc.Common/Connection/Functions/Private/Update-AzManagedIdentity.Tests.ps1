# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\DSCClassResources.TestInitialization.ps1

Describe 'Update-AzManagedIdentity' {

    Context 'When OrganizationName is set' {

        It 'Should update the global variable DSCAZDO_ManagedIdentityToken' {
            $organizationName = 'MyOrganization'
            $global:DSCAZDO_OrganizationName = $organizationName

            Update-AzManagedIdentity

            $global:DSCAZDO_ManagedIdentityToken | Should -Not -Be $null
        }
    }

    Context 'When OrganizationName is not set' {

        It 'Should throw an error' {
            { Update-AzManagedIdentity } | Should -Throw
        }
    }
}
