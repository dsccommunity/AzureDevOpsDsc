<#
    .DESCRIPTION
        TThis example shows how to update the group membership.
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDoGroupMember 'UpdateAzDoGroupMember'
        {
            Ensure               = 'Present'
            GroupName            = '[ProjectName|OrganizationName]\GroupName'
            GroupMembers         = @(
                '[Project]\New Group Name'
                '[OrganizationName]\Project Collection Administrators'
            )
        }
    }
}
