Describe 'Refresh-CacheIdentity' {
    Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('TypeA', 'TypeB', 'TypeC') }
    Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
        return [PSCustomObject]@{
            id = 'id123'
            descriptor = 'descriptor123'
            subjectDescriptor = 'subjectDescriptor123'
            providerDisplayName = 'providerDisplayName123'
            isActive = $true
            isContainer = $false
        }
    }
    Mock -CommandName Add-CacheItem
    Mock -CommandName Get-CacheObject -MockWith { return @() }
    Mock -CommandName Set-CacheObject

    $global:DSCAZDO_OrganizationName = 'TestOrg'
    $identity = [PSCustomObject]@{ descriptor = 'descriptor123' }
    $key = 'testKey'
    $cacheType = 'TypeA'

    It 'Adds ACLIdentity to Identity' {
        Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType

        $identity.PSObject.Properties.Match('ACLIdentity').Count | Should -Be 1
        $identity.ACLIdentity.id | Should -Be 'id123'
    }

    It 'Calls Add-CacheItem with correct parameters' {
        Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType

        Assert-MockCalled -CommandName Add-CacheItem -Exactly 1 -Scope It -ArgumentList @{
            Key = $key
            Value = $identity
            Type = $cacheType
            SuppressWarning = $true
        }
    }

    It 'Calls Set-CacheObject with current cache' {
        Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType

        Assert-MockCalled -CommandName Set-CacheObject -Exactly 1 -Scope It
    }
}

