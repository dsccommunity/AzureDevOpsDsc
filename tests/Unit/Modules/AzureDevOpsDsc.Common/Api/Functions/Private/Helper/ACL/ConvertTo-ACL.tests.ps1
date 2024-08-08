Describe "ConvertTo-ACL" {
    Mock -CommandName New-ACLToken -MockWith { return @{ Token = "mockToken" } }
    Mock -CommandName ConvertTo-ACEList -MockWith { return @( @{ Identity = "User1"; Permissions = "Read" }, @{ Identity = "User2"; Permissions = "Read, Write" } ) }
    Mock -CommandName Group-ACEs -MockWith { param($ACEs) return $ACEs }

    $permissions = @(
        @{
            Identity    = 'User1'
            Permissions = 'Read'
        },
        @{
            Identity    = 'User2'
            Permissions = 'Read', 'Write'
        }
    )

    It "should return an ACL with correct properties" {
        $result = ConvertTo-ACL -Permissions $permissions -SecurityNamespace 'Namespace1' -isInherited $true -OrganizationName 'Org1' -TokenName 'Token1'

        $result | Should -Not -BeNullOrEmpty
        $result.token.Token | Should -Be "mockToken"
        $result.aces | Should -HaveCount 2
        $result.inherited | Should -Be $true
    }

    It "should return a warning if no ACEs are created" {
        Mock -CommandName ConvertTo-ACEList -MockWith { return @() }
        $result = ConvertTo-ACL -Permissions $permissions -SecurityNamespace 'Namespace1' -isInherited $true -OrganizationName 'Org1' -TokenName 'Token1'
        $result.aces | Should -HaveCount 0
    }
}

