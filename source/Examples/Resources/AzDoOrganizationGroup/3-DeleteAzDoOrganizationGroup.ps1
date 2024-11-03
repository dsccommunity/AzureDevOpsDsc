<#
    .DESCRIPTION
        This example shows how to remove a Orgnaization Group
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoOrganizationGroup 'DeleteAzDoOrganizationGroup'
        {
            Ensure               = 'Absent'
            GroupName            = 'Updated Group Name'
        }
    }
}
