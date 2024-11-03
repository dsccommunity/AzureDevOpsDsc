<#
    .DESCRIPTION
        This example shows how to add the Git Repository
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoGitRepository 'AddGitRepository'
        {
            Ensure               = 'Present'
            ProjectName          = 'Test Project'
            RepositoryName       = 'Test Repository'
        }
    }
}
