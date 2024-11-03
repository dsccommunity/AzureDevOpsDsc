<#
    .DESCRIPTION
        This example shows how to ensure that the Git repository permissions.
#>

# Refer to Authentication\1-NewAuthenticationPAT.ps1 for the New-AzDoAuthenticationProvider command
New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoGitPermission 'AddGitPermission'
        {
            Ensure               = 'Present'
            ProjectName          = 'Test Project'
            RepositoryName       = 'Test Repository'
            isInherited          = $true
            Permissions          = @(
                @{
                    Identity = '[Project]\Contributors'
                    Permission = @{
                        read        = 'allow'
                        contribute  = 'allow'
                    }
                },
                @{
                    Identity = '[Project]\Readers'
                    Permission = @{
                        read       = 'allow'
                    }
                }
            )
        }
    }
}
