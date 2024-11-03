<#
    .DESCRIPTION
        This example shows how to remove a Project Group
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoProjectGroup 'RemoveProjectGroup' {
            Ensure              = 'Absent'
            GroupName           = 'SampleProjectGroup'
            ProjectName         = 'SampleProject'
        }
    }
}
