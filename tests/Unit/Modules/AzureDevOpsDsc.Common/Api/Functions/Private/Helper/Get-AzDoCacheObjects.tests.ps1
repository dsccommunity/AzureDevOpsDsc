Describe 'Get-AzDoCacheObjects' {
    It 'Returns an array' {
        $result = Get-AzDoCacheObjects
        $result | Should -BeOfType 'System.Array'
    }

    It 'Returns an array with 13 elements' {
        $result = Get-AzDoCacheObjects
        $result.Length | Should -Be 13
    }

    It 'Contains expected elements' {
        $expectedElements = @(
            'Project',
            'Team',
            'Group',
            'SecurityDescriptor',
            'LiveGroups',
            'LiveProjects',
            'LiveUsers',
            'LiveGroupMembers',
            'LiveRepositories',
            'LiveServicePrinciples',
            'LiveACLList',
            'LiveProcesses',
            'SecurityNamespaces'
        )
        $result = Get-AzDoCacheObjects
        $result | Should -Be $expectedElements
    }
}

