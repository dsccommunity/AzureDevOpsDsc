powershell
# Unit Tests for Find-Identity function
Describe 'Find-Identity Function Tests' {
    # Mock Get-CacheObject to return test data
    Mock Get-CacheObject {
        Param(
            [string]$CacheType
        )
        
        switch ($CacheType) {
            'LiveGroups' { 
                @{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'groupDescriptor'; id = 'groupId'; originId = 'groupOrigin'; principalName = 'groupPrincipal'; displayName = 'groupDisplay' } } }
            }
            'LiveUsers' { 
                @{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'userDescriptor'; id = 'userId'; originId = 'userOrigin'; principalName = 'userPrincipal'; displayName = 'userDisplay' } } }
            }
            'LiveServicePrinciples' {
                @{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'spDescriptor'; id = 'spId'; originId = 'spOrigin'; principalName = 'spPrincipal'; displayName = 'spDisplay' } } }
            }
        }
    }

    # Mock Get-DevOpsDescriptorIdentity to return test identity
    Mock Get-DevOpsDescriptorIdentity {
        Param(
            [string]$OrganizationName,
            [string]$Descriptor
        )
        
        return [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'apiDescriptor'; id = 'apiId'; originId = 'apiOrigin'; principalName = 'apiPrincipal'; displayName = 'apiDisplay' } }
    }

    It 'Should return group identity for valid group descriptor' {
        $result = Find-Identity -Name 'groupDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'
        
        $result.value.ACLIdentity.descriptor | Should -Be 'groupDescriptor'
    }

    It 'Should return user identity for valid user descriptor' {
        $result = Find-Identity -Name 'userDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'
        
        $result.value.ACLIdentity.descriptor | Should -Be 'userDescriptor'
    }

    It 'Should return null for non-existent descriptor' {
        $result = Find-Identity -Name 'nonExistentDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'
        
        $result | Should -BeNullOrEmpty
    }

    It 'Should return identity from API if not found in cache' {
        Remove-Mock Get-CacheObject
        Mock Get-CacheObject {
            @{}
        }
        
        $result = Find-Identity -Name 'apiDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'
        
        $result.ACLIdentity.descriptor | Should -Be 'apiDescriptor'
    }

    It 'Should return null for multiple identities with the same name' {
        Mock Get-CacheObject {
            @{
                value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'duplicateDescriptor'; id = 'duplicateId' } }
            }, @{
                value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'duplicateDescriptor'; id = 'duplicateId' } }
            }
        }

        $result = Find-Identity -Name 'duplicateDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'
        
        $result | Should -BeNullOrEmpty
    }
}

