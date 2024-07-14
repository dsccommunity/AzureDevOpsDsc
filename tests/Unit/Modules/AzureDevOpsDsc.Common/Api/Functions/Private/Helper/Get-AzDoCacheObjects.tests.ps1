powershell
Describe 'Get-AzDoCacheObjects' {
    It 'Should return an array of cache objects' {
        $expectedObjects = @(
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
            'SecurityNamespaces'
        )

        $result = Get-AzDoCacheObjects

        $result | Should -BeOfType 'System.Object[]'
        $result | Should -Be $expectedObjects
        $result.Count | Should -Be $expectedObjects.Count
    }

    It 'Should return the correct cache object names' {
        $expectedObjects = @(
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
            'SecurityNamespaces'
        )

        $result = Get-AzDoCacheObjects

        foreach ($object in $expectedObjects) {
            $result | Should -Contain $object
        }
    }
}

