<#
.SYNOPSIS
    Test suite for the New-AzManagedIdentity function.

.DESCRIPTION
    This test suite validates the functionality of the New-AzManagedIdentity function, ensuring it sets global variables correctly and handles token acquisition.
#>

# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {

    Describe "New-AzManagedIdentity Function Tests" {

        Mock Get-AzManagedIdentityToken {
            return @{
                access_token = "mocked_access_token"
                expires_on   = (Get-Date).AddHours(1).ToUniversalTime().Subtract([datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)).TotalSeconds
                expires_in   = 3600
                resource     = "https://management.azure.com/"
                token_type   = "Bearer"
            }
        }

        It "Sets the global organization name and managed identity token" {
            # Arrange
            $orgName = "TestOrganization"

            # Act
            New-AzManagedIdentity -OrganizationName $orgName

            # Assert
            $Global:DSCAZDO_OrganizationName | Should -Be $orgName
            $Global:DSCAZDO_ManagedIdentityToken | Should -Not -Be $null
            $Global:DSCAZDO_ManagedIdentityToken.access_token | Should -Be "mocked_access_token"
        }

        It "Sets the global managed identity token to null if Get-AzManagedIdentityToken fails" {
            # Arrange
            Mock Get-AzManagedIdentityToken { throw "Failed to get token." }
            $orgName = "TestOrganization"

            # Act / Assert
            { New-AzManagedIdentity -OrganizationName $orgName } | Should -Throw "Failed to get token."
            $Global:DSCAZDO_ManagedIdentityToken | Should -Be $null
        }
    }

}
