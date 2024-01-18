# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\DSCClassResources.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {

    Describe 'New-AzManagedIdentity' {

        Context 'When providing valid OrganizationName' {

            It 'Should set the global variable DSCAZDO_OrganizationName' {
                $organizationName = 'MyOrganization'
                New-AzManagedIdentity -OrganizationName $organizationName

                $global:DSCAZDO_OrganizationName | Should -Be $organizationName
            }

            It 'Should set the global variable DSCAZDO_ManagedIdentityToken' {
                $organizationName = 'MyOrganization'
                New-AzManagedIdentity -OrganizationName $organizationName

                $global:DSCAZDO_ManagedIdentityToken | Should -Not -Be $null
            }
        }

        Context 'When not providing OrganizationName' {

            It 'Should not set the global variable DSCAZDO_OrganizationName' {
                New-AzManagedIdentity

                $global:DSCAZDO_OrganizationName | Should -Be $null
            }

            It 'Should not set the global variable DSCAZDO_ManagedIdentityToken' {
                New-AzManagedIdentity

                $global:DSCAZDO_ManagedIdentityToken | Should -Be $null
            }
        }
    }
}
