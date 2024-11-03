
<#
    .DESCRIPTION
        This example shows how to ensure that the Azure DevOps project
        called 'Test Project' exists (or is added if it does not exist).
#>

# Refer to Authentication\1-NewAuthenticationPAT.ps1 for the New-AzDoAuthenticationProvider command
New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDevOpsProject 'AddProject'
        {
            Ensure               = 'Present'
            ProjectName          = 'Test Project'
            ProjectDescription   = 'A Test Project'
            SourceControlType    = 'Git'
        }

    }
}
