
# Pester Unit Tests for Test-ACLListforChanges

Describe "Test-ACLListforChanges" {
    # Sample ACL objects for testing
    $acl1 = @{
        aces = @(
            @{ Identity = @{ value = @{ originId = "user1" } }; isInherited = $false; Permissions = @{ Allow = @{ Bit = 1 }; Deny = @{ Bit = 0 } } }
            @{ Identity = @{ value = @{ originId = "user2" } }; isInherited = $false; Permissions = @{ Allow = @{ Bit = 2 }; Deny = @{ Bit = 0 } } }
        )
    }

    $acl2 = @{
        aces = @(
            @{ Identity = @{ value = @{ originId = "user1" } }; isInherited = $false; Permissions = @{ Allow = @{ Bit = 1 }; Deny = @{ Bit = 0 } } }
            @{ Identity = @{ value = @{ originId = "user2" } }; isInherited = $false; Permissions = @{ Allow = @{ Bit = 2 }; Deny = @{ Bit = 0 } } }
        )
    }

    $acl3 = @{
        aces = @(
            @{ Identity = @{ value = @{ originId = "user1" } }; isInherited = $false; Permissions = @{ Allow = @{ Bit = 1 }; Deny = @{ Bit = 0 } } }
            @{ Identity = @{ value = @{ originId = "user3" } }; isInherited = $false; Permissions = @{ Allow = @{ Bit = 4 }; Deny = @{ Bit = 0 } } }
        )
    }

    # Mock Get-BitwiseOrResult function if it is used inside Test-ACLListforChanges
    Mock -CommandName Get-BitwiseOrResult -MockWith { param($bit) return $bit }

    It "returns 'Unchanged' if ACLs are the same" {
        $result = Test-ACLListforChanges -ReferenceACLs $acl1 -DifferenceACLs $acl2
        $result.status | Should -Be "Unchanged"
    }

    It "returns 'Changed' if ACL counts are different" {
        $acl2.aces.RemoveAt(0)
        $result = Test-ACLListforChanges -ReferenceACLs $acl1 -DifferenceACLs $acl2
        $result.status | Should -Be "Changed"
    }

    It "returns 'Changed' if any ACL is different" {
        $result = Test-ACLListforChanges -ReferenceACLs $acl1 -DifferenceACLs $acl3
        $result.status | Should -Be "Changed"
    }

    It "returns 'Missing' if Reference ACL is null" {
        $result = Test-ACLListforChanges -ReferenceACLs $null -DifferenceACLs $acl3
        $result.status | Should -Be "Missing"
    }

    It "returns 'NotFound' if Difference ACL is null" {
        $result = Test-ACLListforChanges -ReferenceACLs $acl1 -DifferenceACLs $null
        $result.status | Should -Be "NotFound"
    }

    It "returns 'Changed' if ACL is inherited flag is different" {
        $acl4 = $acl1.Clone()
        $acl4.aces[0].isInherited = $true
        $result = Test-ACLListforChanges -ReferenceACLs $acl1 -DifferenceACLs $acl4
        $result.status | Should -Be "Changed"
    }

    It "returns 'Changed' if Allow ACEs are different" {
        $acl4 = $acl1.Clone()
        $acl4.aces[0].Permissions.Allow.Bit = 8
        $result = Test-ACLListforChanges -ReferenceACLs $acl1 -DifferenceACLs $acl4
        $result.status | Should -Be "Changed"
    }

    It "returns 'Changed' if Deny ACEs are different" {
        $acl4 = $acl1.Clone()
        $acl4.aces[0].Permissions.Deny.Bit = 8
        $result = Test-ACLListforChanges -ReferenceACLs $acl1 -DifferenceACLs $acl4
        $result.status | Should -Be "Changed"
    }

}

