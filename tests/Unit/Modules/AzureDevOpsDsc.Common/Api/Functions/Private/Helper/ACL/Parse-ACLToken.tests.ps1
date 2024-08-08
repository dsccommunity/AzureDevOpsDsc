Describe 'Parse-ACLToken' {
    BeforeAll {
        $script:LocalizedDataAzACLTokenPatten = @{
            OrganizationGit    = '^org:(.+)$'
            GitProject         = '^project:(.+)$'
            GitRepository      = '^repo:(.+)$'
            GitBranch          = '^branch:(.+)$'
            ResourcePermission = '^resource:(.+)$'
            GroupPermission    = '^group:(.+)$'
        }
    }

    It 'Should parse OrganizationGit token correctly' {
        $token = "org:testOrg"
        $SecurityNamespace = "Git Repositories"
        $result = Parse-ACLToken -Token $token -SecurityNamespace $SecurityNamespace

        $result.type | Should -Be 'OrganizationGit'
        $result._token | Should -Be $token
    }

    It 'Should parse GitProject token correctly' {
        $token = "project:testProject"
        $SecurityNamespace = "Git Repositories"
        $result = Parse-ACLToken -Token $token -SecurityNamespace $SecurityNamespace

        $result.type | Should -Be 'GitProject'
        $result._token | Should -Be $token
    }

    It 'Should throw for unrecognized Git Repositories token' {
        $token = "unknown:test"
        $SecurityNamespace = "Git Repositories"
        { Parse-ACLToken -Token $token -SecurityNamespace $SecurityNamespace } | Should -Throw "Token '$token' is not recognized."
    }

    It 'Should parse ResourcePermission token correctly' {
        $token = "resource:testResource"
        $SecurityNamespace = "Identity"
        $result = Parse-ACLToken -Token $token -SecurityNamespace $SecurityNamespace

        $result.type | Should -Be 'ResourcePermission'
        $result._token | Should -Be $token
    }

    It 'Should parse GroupPermission token correctly' {
        $token = "group:testGroup"
        $SecurityNamespace = "Identity"
        $result = Parse-ACLToken -Token $token -SecurityNamespace $SecurityNamespace

        $result.type | Should -Be 'GroupPermission'
        $result._token | Should -Be $token
    }

    It 'Should throw for unrecognized Identity token' {
        $token = "unknown:test"
        $SecurityNamespace = "Identity"
        { Parse-ACLToken -Token $token -SecurityNamespace $SecurityNamespace } | Should -Throw "Token '$token' is not recognized."
    }
}

