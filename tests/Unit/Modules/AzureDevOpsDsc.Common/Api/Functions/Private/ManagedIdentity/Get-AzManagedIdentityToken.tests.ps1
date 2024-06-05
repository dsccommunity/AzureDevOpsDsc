. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

Describe 'Get-AzManagedIdentityToken' {
    Mock Invoke-AzDevOpsApiRestMethod { return @{ access_token = "fake-access-token" } }
    Mock New-ManagedIdentityToken { return @{ AccessToken = "fake-access-token"; TokenType = "Bearer" } }
    Mock Test-Token { return $true }

    It 'Successfully retrieves a managed identity token without verification' {
        $result = Get-AzManagedIdentityToken -OrganizationName "Contoso"
        $result.AccessToken | Should -Be "fake-access-token"
        $result.token_type | Should -Be "Bearer"
    }

    It 'Successfully retrieves a managed identity token with verification' {
        $result = Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify
        $result.AccessToken | Should -Be "fake-access-token"
        $result.token_type | Should -Be "Bearer"
    }

    It 'Throws an error when access token is not returned' {
        Mock Invoke-AzDevOpsApiRestMethod { return @{} }

        { Get-AzManagedIdentityToken -OrganizationName "Contoso" } | Should -Throw "Access token not returned from Azure Instance Metadata Service"
    }

    It 'Throws an error when verification fails' {
        Mock Test-Token { return $false }

        { Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify } | Should -Throw "Failed to call the Azure DevOps API."
    }
}

