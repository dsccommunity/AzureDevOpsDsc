powershell
Describe 'Group-ACEs' {
    Mock -ModuleName Pester -MemberName Group-Object -MockWith {
        return @(
            [PSCustomObject]@{ Count = 1; Group = @(@{ Identity = [PSCustomObject]@{ value = [PSCustomObject]@{ originId = 'user1' } }; Permissions = [PSCustomObject]@{ Deny = @(); Allow = @(1, 2); DescriptorType = 'TypeA' } }) }
            [PSCustomObject]@{ Count = 2; Group = @(@{ Identity = [PSCustomObject]@{ value = [PSCustomObject]@{ originId = 'user2' } }; Permissions = [PSCustomObject]@{ Deny = @(1); Allow = @(2); DescriptorType = 'TypeB' } }, @{ Identity = [PSCustomObject]@{ value = [PSCustomObject]@{ originId = 'user2' } }; Permissions = [PSCustomObject]@{ Deny = @(); Allow = @(2, 3); DescriptorType = 'TypeB' } }) }
        )
    }
    
    It 'Returns empty list if no ACEs are provided' {
        $result = Group-ACEs -ACEs @()
        $result | Should -BeNullOrEmpty
    }

    It 'Adds single identity correctly to the ACE list' {
        $aces = @(@{ Identity = [PSCustomObject]@{ value = [PSCustomObject]@{ originId = 'user1' } }; Permissions = [PSCustomObject]@{ Deny = @(); Allow = @(1, 2); DescriptorType = 'TypeA' } })
        $result = Group-ACEs -ACEs $aces
        $result | Should -HaveCount 1
        $result[0].Identity.value.originId | Should -Be 'user1'
    }

    It 'Groups multiple identities by permissions correctly' {
        $aces = @(
            @{ Identity = [PSCustomObject]@{ value = [PSCustomObject]@{ originId = 'user2' } }; Permissions = [PSCustomObject]@{ Deny = @(1); Allow = @(2); DescriptorType = 'TypeB' } },
            @{ Identity = [PSCustomObject]@{ value = [PSCustomObject]@{ originId = 'user2' } }; Permissions = [PSCustomObject]@{ Deny = @(); Allow = @(2, 3); DescriptorType = 'TypeB' } }
        )
        $result = Group-ACEs -ACEs $aces
        $result | Should -HaveCount 1
        $result[0].Identity.value.originId | Should -Be 'user2'
        $result[0].Permissions.Deny | Should -Contain 1
        $result[0].Permissions.Allow | Should -Contain 2
        $result[0].Permissions.Allow | Should -Contain 3
        $result[0].Permissions.DescriptorType | Should -Be 'TypeB'
    }
}

