Describe 'Get-DevOpsACL' {
    Mock Get-AzDevOpsApiVersion { return '5.1-preview' }
    Mock Invoke-AzDevOpsApiRestMethod
    Mock Add-CacheItem
    Mock Export-CacheObject

    It 'Returns ACL list when called with valid parameters and items are present' {
        $mockedAclList = @{
            value = @('item1', 'item2')
        }

        Mock Invoke-AzDevOpsApiRestMethod { return $mockedAclList }

        $result = Get-DevOpsACL -OrganizationName 'OrgName' -SecurityDescriptorId 'SecurityDescId'

        $result | Should -Not -BeNullOrEmpty
        $result | Should -Contain 'item1'
        $result | Should -Contain 'item2'
        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1
        Assert-MockCalled -CommandName Add-CacheItem -Times 1
        Assert-MockCalled -CommandName Export-CacheObject -Times 1
    }

    It 'Returns null when no items are present in ACL list' {
        $mockedEmptyAclList = @{
            value = @()
        }

        Mock Invoke-AzDevOpsApiRestMethod { return $mockedEmptyAclList }

        $result = Get-DevOpsACL -OrganizationName 'OrgName' -SecurityDescriptorId 'SecurityDescId'

        $result | Should -BeNull
        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1
        Assert-MockCalled -CommandName Add-CacheItem -Times 0
        Assert-MockCalled -CommandName Export-CacheObject -Times 0
    }

    It 'Returns null when ACL list returns null' {
        Mock Invoke-AzDevOpsApiRestMethod { return $null }

        $result = Get-DevOpsACL -OrganizationName 'OrgName' -SecurityDescriptorId 'SecurityDescId'

        $result | Should -BeNull
        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1
        Assert-MockCalled -CommandName Add-CacheItem -Times 0
        Assert-MockCalled -CommandName Export-CacheObject -Times 0
    }
}

