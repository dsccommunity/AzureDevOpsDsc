
# Unit tests for ConvertTo-ACETokenList function

# Load the function script
. .\ConvertTo-ACETokenList.ps1

Describe "ConvertTo-ACETokenList Tests" {

    BeforeEach {
        # Mock Get-CacheItem to return a mock SecurityDescriptor
        Mock Get-CacheItem {
            return @{
                actions = @(
                    @{ displayName = "Read"; name = "read" },
                    @{ displayName = "Write"; name = "write" },
                    @{ displayName = "Execute"; name = "execute" }
                )
            }
        }
    }

    It "should return an empty list when SecurityDescriptor is not found" {
        # Mock to return $null for not found SecurityDescriptor
        Mock Get-CacheItem { return $null }

        $result = ConvertTo-ACETokenList -SecurityNamespace "TestNamespace" -ACEPermissions @(
            @{ "Read" = "Allow"; "Write" = "Deny" }
        )

        $result | Should -BeNullOrEmpty
    }

    It "should correctly process Allow and Deny permissions" {
        $acePermissions = @(
            @{ "Read" = "Allow"; "Write" = "Deny" },
            @{ "Execute" = "Allow"; "Read" = "Deny" }
        )
        $result = ConvertTo-ACETokenList -SecurityNamespace "TestNamespace" -ACEPermissions $acePermissions

        $result | Should -HaveCount 2
        $result[0].DescriptorType | Should -Be "TestNamespace"
        $result[0].Allow.displayName | Should -Contain "Read"
        $result[0].Deny.displayName | Should -Contain "Write"
        $result[1].Allow.displayName | Should -Contain "Execute"
        $result[1].Deny.displayName | Should -Contain "Read"
    }

    It "should filter out permissions not found in the SecurityDescriptor" {
        $acePermissions = @(
            @{ "UnknownPermission" = "Allow"; "Read" = "Deny" }
        )
        $result = ConvertTo-ACETokenList -SecurityNamespace "TestNamespace" -ACEPermissions $acePermissions

        $result | Should -HaveCount 1
        $result[0].Allow | Should -BeNullOrEmpty
        $result[0].Deny.displayName | Should -Contain "Read"
    }
}

# End of Pester tests for ConvertTo-ACETokenList

