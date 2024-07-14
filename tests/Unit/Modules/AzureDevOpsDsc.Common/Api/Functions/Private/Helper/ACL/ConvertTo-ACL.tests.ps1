powershell
# ConvertTo-ACL.Tests.ps1

# Import the module containing the ConvertTo-ACL function
# Import-Module '<module-path>'

Describe 'ConvertTo-ACL' {
    BeforeEach {
        # Mock dependencies
        Mock New-ACLToken {
            return @{
                SecurityNamespace  = $SecurityNamespace
                TokenName          = $TokenName
            }
        }

        Mock ConvertTo-ACEList {
            return @(
                @{
                    Identity    = 'User1'
                    Permissions = 'Read'
                },
                @{
                    Identity    = 'User2'
                    Permissions = 'Read', 'Write'
                }
            )
        }

        Mock Group-ACEs {
            param (
                [Parameter(Mandatory = $true)]
                [hashtable[]]$ACEs
            )

            return $ACEs | Sort-Object -Property Identity -Unique
        }
    }

    It 'should create ACL with correct parameters' {
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

        $result = ConvertTo-ACL -Permissions $permissions -SecurityNamespace 'Namespace1' -isInherited $true -OrganizationName 'Org1' -TokenName 'Token1'

        $result | Should -Not -BeNullOrEmpty
        $result.token.SecurityNamespace | Should -Be 'Namespace1'
        $result.token.TokenName | Should -Be 'Token1'
        $result.inherited | Should -Be $true
        $result.aces | Should -HaveCount 2
        $result.aces[0].Identity | Should -Be 'User1'
        $result.aces[1].Identity | Should -Be 'User2'
    }
}

