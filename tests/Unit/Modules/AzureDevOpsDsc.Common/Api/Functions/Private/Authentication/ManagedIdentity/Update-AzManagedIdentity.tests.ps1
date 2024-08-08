Describe "Update-AzManagedIdentity" {
    Mock -CommandName Get-AzManagedIdentityToken

    Context "When the Global Organization Name is not set" {
        It "Throws an error" {
            $Global:DSCAZDO_OrganizationName = $null

            { Update-AzManagedIdentity } | Should -Throw "[Update-AzManagedIdentity] Organization Name is not set. Please run 'New-AzManagedIdentity -OrganizationName <OrganizationName>'"
        }
    }

    Context "When the Global Organization Name is set" {
        BeforeEach {
            $Global:DSCAZDO_OrganizationName = "Contoso"
            $Global:DSCAZDO_AuthenticationToken = "oldToken"
        }

        It "Clears the existing token" {
            Update-AzManagedIdentity
            $Global:DSCAZDO_AuthenticationToken | Should -BeNullOrEmpty
        }

        It "Calls Get-AzManagedIdentityToken with the correct organization name" {
            Mock -CommandName Get-AzManagedIdentityToken -MockWith { return "newToken" }

            Update-AzManagedIdentity
            Assert-MockCalled -CommandName Get-AzManagedIdentityToken -Times 1 -Exactly -ParameterFilter { $OrganizationName -eq "Contoso" }
        }

        It "Sets the Global Authentication Token to the new token" {
            Mock -CommandName Get-AzManagedIdentityToken -MockWith { return "newToken" }

            Update-AzManagedIdentity
            $Global:DSCAZDO_AuthenticationToken | Should -Be "newToken"
        }
    }
}

