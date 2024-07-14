powershell
Describe 'Remove-xAzDoGroupMember Tests' {

    Mock -CommandName Find-AzDoIdentity -MockWith {
        return @{ principalName = 'mockUser@domain.com' }
    }

    Mock -CommandName Get-CacheItem -MockWith {
        return @(
            @{ principalName = 'userA@domain.com' },
            @{ principalName = 'userB@domain.com' }
        )
    }

    Mock -CommandName Remove-DevOpsGroupMember -MockWith {
        return @{ Result = 'Success' }
    }

    Mock -CommandName Remove-CacheItem
    Mock -CommandName Set-CacheObject

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'MockOrganization'
        $Global:AzDoLiveGroupMembers = 'MockMembers'
    }

    It 'Should remove group members correctly' {
        $GroupName = 'TestGroup'
        $result = Remove-xAzDoGroupMember -GroupName $GroupName

        $result | Should -BeOfType [Object[]]

        Get-Command -CommandType Function | Where-Object { $_.Name -eq 'Remove-DevOpsGroupMember' } | ForEach-Object {
            (Get-MockDynamicParameters $_.Name).Name | Should -Contain 'GroupIdentity'
            (Get-MockDynamicParameters $_.Name).Name | Should -Contain 'ApiUri'
        }

        Assert-MockCalled -CommandName Find-AzDoIdentity -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Times 1
        Assert-MockCalled -CommandName Remove-DevOpsGroupMember -Times 2
        Assert-MockCalled -CommandName Remove-CacheItem -Times 1
        Assert-MockCalled -CommandName Set-CacheObject -Times 1
    }

    It 'Should handle an empty members list' {
        Mock -CommandName Get-CacheItem -MockWith {
            return @()
        }

        $GroupName = 'TestGroup'
        $result = Remove-xAzDoGroupMember -GroupName $GroupName

        Assert-MockCalled -CommandName Find-AzDoIdentity -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Times 1
        Assert-MockNotCalled -CommandName Remove-DevOpsGroupMember
        Assert-MockNotCalled -CommandName Remove-CacheItem
        Assert-MockNotCalled -CommandName Set-CacheObject
    }
}

