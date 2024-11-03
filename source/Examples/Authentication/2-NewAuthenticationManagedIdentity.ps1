<#
    .DESCRIPTION
        This example shows how to authenticate with Azure DevOps using a Managed Identity.
#>

# Using New-AzDoAuthenticationProvider
New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

