
# ConvertTo-FormattedACL.Tests.ps1

Describe "ConvertTo-FormattedACL" {
    Mock -CommandName Find-Identity -MockWith { return @{Id = "TestIdentity"} }
    Mock -CommandName Format-ACEs -MockWith { return @{Permissions = "TestPermissions"} }
    Mock -CommandName Parse-ACLToken -MockWith { return "FormattedToken" }

    Context "When ACL has token and ACE entries" {
        $ACL = [PSCustomObject]@{
            token = "TestToken"
            acesDictionary = [ordered]@{
                "TestACE" = @{
                    allow = "Read"
                    deny  = "None"
                }
            }
            inheritPermissions = $true
        }

        It "Should format ACL properly" {
            $result = $ACL | ConvertTo-FormattedACL -SecurityNamespace "TestNamespace" -OrganizationName "TestOrg"
            $result | Should -HaveCount 1
            $result[0].token | Should -Be "FormattedToken"
            $result[0].aces | Should -HaveCount 1
            $result[0].aces[0].Identity.Id | Should -Be "TestIdentity"
            $result[0].aces[0].Permissions.Permissions | Should -Be "TestPermissions"
        }
    }

    Context "When ACL has no token" {
        $ACL = [PSCustomObject]@{
            token = $null
            acesDictionary = [ordered]@{
                "TestACE" = @{
                    allow = "Read"
                    deny  = "None"
                }
            }
            inheritPermissions = $true
        }

        It "Should skip ACL without token" {
            $result = $ACL | ConvertTo-FormattedACL -SecurityNamespace "TestNamespace" -OrganizationName "TestOrg"
            $result | Should -BeEmpty
        }
    }

    Context "When ACL has empty ACE entries" {
        $ACL = [PSCustomObject]@{
            token = "TestToken"
            acesDictionary = [ordered]@{}
            inheritPermissions = $true
        }

        It "Should skip ACL with empty ACE entries" {
            $result = $ACL | ConvertTo-FormattedACL -SecurityNamespace "TestNamespace" -OrganizationName "TestOrg"
            $result | Should -BeEmpty
        }
    }

    Context "When ACEs are empty after processing" {
        $ACL = [PSCustomObject]@{
            token = "TestToken"
            acesDictionary = [ordered]@{
                "TestACE" = @{ allow = $null; deny = $null }
            }
            inheritPermissions = $true
        }

        It "Should skip ACL with empty ACEs after processing" {
            $result = $ACL | ConvertTo-FormattedACL -SecurityNamespace "TestNamespace" -OrganizationName "TestOrg"
            $result | Should -BeEmpty
        }
    }
}

