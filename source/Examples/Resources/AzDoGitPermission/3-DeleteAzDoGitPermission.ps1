<#
    .DESCRIPTION
        This example shows how to remove Git repository permissions.
#>

# Refer to Authentication\1-NewAuthenticationPAT.ps1 for the New-AzDoAuthenticationProvider command
New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoGitPermission 'DeleteGitPermission'
        {
            Ensure               = 'Present'
            ProjectName          = 'Test Project'
            RepositoryName       = 'Test Repository'
            isInherited          = $true
            # Note: Permissions can be empty to remove all permissions
            # Ensure = 'Absent' is not required.
            Permissions          = @()
        }
    }
}
