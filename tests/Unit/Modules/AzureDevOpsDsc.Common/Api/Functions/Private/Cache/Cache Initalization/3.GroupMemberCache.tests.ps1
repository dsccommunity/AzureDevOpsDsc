Describe "AzDoAPI_3_GroupMemberCache" {
    Mock Get-CacheObject {
        return @{
            'LiveGroups' = @( [PSCustomObject]@{ Value = [PSCustomObject]@{ descriptor = 'group1' }; Key = 'group1' } )
            'LiveUsers' = @( [PSCustomObject]@{ descriptor = 'user1' } )
        }
    }

    Mock List-DevOpsGroupMembers {
        return @{
            memberDescriptor = 'user1'
        }
    }

    Mock Add-CacheItem { }

    Mock Export-CacheObject { }

    It "uses global organization name if parameter is not provided" {
        $Global:DSCAZDO_OrganizationName = "globalOrg"
        AzDoAPI_3_GroupMemberCache

        Assert-MockCalled List-DevOpsGroupMembers -Exactly -Scope It -Parameters @{ Organization = "globalOrg"; GroupDescriptor = 'group1' }
    }

    It "uses provided organization name if parameter is provided" {
        AzDoAPI_3_GroupMemberCache -OrganizationName 'paramOrg'

        Assert-MockCalled List-DevOpsGroupMembers -Exactly -Scope It -Parameters @{ Organization = "paramOrg"; GroupDescriptor = 'group1' }
    }

    It "adds members to cache" {
        AzDoAPI_3_GroupMemberCache -OrganizationName 'testOrg'

        Assert-MockCalled Add-CacheItem -Exactly 1 -Scope It

        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It
    }

    It "skips groups with no members" {
        Mock List-DevOpsGroupMembers {
            return @{ memberDescriptor = $null }
        }

        AzDoAPI_3_GroupMemberCache -OrganizationName 'testOrg'

        Assert-MockCalled Add-CacheItem -Exactly 0 -Scope It
    }
}

