<#
    .DESCRIPTION
        This example shows how to authenticate with Azure DevOps using a Personal Access Token (PAT).
#>

# Using New-AzDoAuthenticationProvider
New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

# Using New-AzDoAuthenticationProvider
New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -SecureStringPersonalAccessToken $SecureStringPAT
