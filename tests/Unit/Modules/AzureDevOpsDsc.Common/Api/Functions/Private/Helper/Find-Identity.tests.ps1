powershell
Describe 'Find-Identity Tests' {
    $mockCacheGroups = @{
        'group1' = [PSCustomObject]@{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'groupDes1'; id = 'groupId1'; originId = 'groupOrigin1'; principalName = 'groupPN1'; displayName = 'groupDisplayName1' } } }
    }
    
    $mockCacheUsers = @{
        'user1' = [PSCustomObject]@{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'userDes1'; id = 'userId1'; originId = 'userOrigin1'; principalName = 'userPN1'; displayName = 'userDisplayName1' } } }
    }
    
    $mockCacheServicePrincipals = @{
        'sp1' = [PSCustomObject]@{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'spDes1'; id = 'spId1'; originId = 'spOrigin1'; principalName = 'spPN1'; displayName = 'spDisplayName1' } } }
    }

    Mock -CommandName Get-CacheObject -MockWith {
        param ($CacheType)
        switch ($CacheType) {
            'LiveGroups' { return $mockCacheGroups.Values }
            'LiveUsers' { return $mockCacheUsers.Values }
            'LiveServicePrinciples' { return $mockCacheServicePrincipals.Values }
        }
    }

    Context 'Cache Lookup' {
        It 'Should find user by descriptor' {
            $result = Find-Identity -Name 'userDes1' -OrganizationName 'org1' -SearchType 'descriptor'
            $result.value.ACLIdentity.descriptor | Should -Be 'userDes1'
        }

        It 'Should return null if multiple identities are found' {
            $mockCacheUsers.Add('group1', $mockCacheGroups['group1']) # Add same group to users to simulate duplicate
            $result = Find-Identity -Name 'groupDes1' -OrganizationName 'org1' -SearchType 'descriptor'
            $result | Should -BeNullOrEmpty
        }

        It 'Should find group by displayName' {
            $result = Find-Identity -Name 'groupDisplayName1' -OrganizationName 'org1' -SearchType 'displayName'
            $result.value.ACLIdentity.displayName | Should -Be 'groupDisplayName1'
        }

        It 'Should return null if no identity found in cache' {
            $result = Find-Identity -Name 'unknownName' -OrganizationName 'org1' -SearchType 'displayName'
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'API Lookup' {
        Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
            param ($OrganizationName, $Descriptor)
            return [PSCustomObject]@{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = $Descriptor; id = 'apiId'; originId = 'apiOrigin'; principalName = 'apiPN'; displayName = 'apiDisplayName' } } }
        }

        It 'Should perform API lookup if no cache hit' {
            $result = Find-Identity -Name 'notInCache' -OrganizationName 'org1' -SearchType 'descriptor'
            $result.value.ACLIdentity.descriptor | Should -Be 'notInCache'
        }

        It 'Should return null if API lookup fails' {
            Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith { throw "API failed" }
            $result = Find-Identity -Name 'errorName' -OrganizationName 'org1' -SearchType 'descriptor'
            $result | Should -BeNullOrEmpty
        }
    }
}

