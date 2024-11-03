<#
    .DESCRIPTION
        This example shows how to update a Project Group
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoProjectGroup 'UpdateProjectGroup' {
            Ensure              = 'Present'
            GroupName           = 'SampleProjectGroup'
            ProjectName         = 'SampleProject'
            GroupDescription    = 'New project group description'
        }
    }
}
