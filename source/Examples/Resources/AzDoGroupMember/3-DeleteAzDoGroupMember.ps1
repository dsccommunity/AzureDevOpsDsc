<#
    .DESCRIPTION
        This example shows how to remove a group membership.
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoGroupMember 'RemoveAzDoGroupMember'
        {
            Ensure               = 'Present'
            GroupName            = '[ProjectName|OrganizationName]\GroupName'
            # Ensure: Absent is not required. Zeroing out the membership is sufficent.
            GroupMembers         = @()
        }
    }
}
