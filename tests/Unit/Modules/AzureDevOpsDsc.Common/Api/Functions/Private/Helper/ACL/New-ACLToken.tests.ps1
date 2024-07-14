
Describe 'New-ACLToken Function Tests' {
    $LocalizedDataAzResourceTokenPatten = @{
        OrganizationGit = 'Contoso'
        GitProject = 'Org/Project'
        GitRepository = 'Org/Project/Repo'
    }

    Mock -CommandName 'Get-CacheItem' -MockWith { return @{ id = "123" } }

    It 'Should return GitOrganization type for OrganizationGit pattern' {
        $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName 'Contoso'
        $result.type | Should -Be 'GitOrganization'
    }

    It 'Should return GitProject type for GitProject pattern' {
        $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName 'Org/Project'
        $result.type | Should -Be 'GitProject'
        $result.projectId | Should -Be '123'
    }

    It 'Should return GitRepository type for GitRepository pattern' {
        $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName 'Org/Project/Repo'
        $result.type | Should -Be 'GitRepository'
        $result.projectId | Should -Be '123'
        $result.RepoId | Should -Be '123'
    }

    It 'Should return GitUnknown type for unknown pattern' {
        $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName 'Unknown/Token'
        $result.type | Should -Be 'GitUnknown'
    }

    It 'Should return UnknownSecurityNamespace for unrecognized namespace' {
        $result = New-ACLToken -SecurityNamespace 'Unknown Namespace' -TokenName 'Org/Project'
        $result.type | Should -Be 'UnknownSecurityNamespace'
    }
}

