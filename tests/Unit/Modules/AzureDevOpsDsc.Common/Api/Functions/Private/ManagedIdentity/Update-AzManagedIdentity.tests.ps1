Describe 'Update-AzManagedIdentity' {
    Mock Get-AzManagedIdentityToken { return "new-token-value" }

    Context 'When organization name is set' {
        It 'Updates the managed identity token' {
            # Set a global variable that the function uses to refresh the token
            $Global:DSCAZDO_OrganizationName = "ContosoOrg"

            # Call the function to update the managed identity token
            Update-AzManagedIdentity -OrganizationName "Contoso"

            # Check if the token was updated
            $Global:DSCAZDO_ManagedIdentityToken | Should -Be "new-token-value"
        }
    }

    Context 'When organization name is not set' {
        It 'Throws an error indicating that the organization name is not set' {
            # Ensure the organization name global variable is not set
            $Global:DSCAZDO_OrganizationName = $null

            # Expect the function to throw when called without setting the organization name
            { Update-AzManagedIdentity -OrganizationName "Contoso" } | Should -Throw -ExpectedMessage "[Update-AzManagedIdentity] Organization Name is not set. Please run 'New-AzManagedIdentity -OrganizationName <OrganizationName>'"
        }
    }

    AfterEach {
        # Clean up the global variables after each test
        Remove-Variable DSCAZDO_OrganizationName -Scope Global -ErrorAction SilentlyContinue
        Remove-Variable DSCAZDO_ManagedIdentityToken -Scope Global -ErrorAction SilentlyContinue
    }
}

# Run the Pester tests
Invoke-Pester
