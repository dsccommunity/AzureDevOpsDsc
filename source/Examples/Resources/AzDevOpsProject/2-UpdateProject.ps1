
<#
    .DESCRIPTION
        This example shows how to ensure that an Azure DevOps project
        with a ProjectName of 'Test Project' can have it's description
        updated to 'A Test Project with a new description'.
#>

# Refer to Authentication\1-NewAuthenticationPAT.ps1 for the New-AzDoAuthenticationProvider command
New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDevOpsProject 'UpdateProject'
        {
            Ensure               = 'Present'
            ProjectName          = 'Test Project'
            ProjectDescription   = 'A Test Project with a new description'  # Updated property
            #SourceControlType    = 'Git'  # Note: Update of this property is not supported

        }

    }
}
