<#
    .DESCRIPTION
        This example shows how to add a Project Group
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoProjectGroup 'AddProjectGroup' {
            Ensure              = 'Present'
            GroupName           = 'SampleProjectGroup'
            ProjectName         = 'SampleProject'
            GroupDescription    = 'This is a sample project group!'
        }
    }
}
