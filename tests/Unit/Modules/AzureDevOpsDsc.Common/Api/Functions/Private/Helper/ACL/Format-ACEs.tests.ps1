powershell
Describe 'Format-ACEs Tests' {
    BeforeAll {
        Function Get-CacheItem {
            param($Key, $Type)
            return @{
                actions = @(
                    @{ bit = 1; Action = 'Read' }
                    @{ bit = 2; Action = 'Write' }
                    @{ bit = 4; Action = 'Delete' }
                )
            }
        }
    }

    Describe 'Valid ACE formatting' {
        It 'Should return ACE with Allow action' {
            $result = Format-ACEs -Allow 1 -Deny 0 -SecurityNamespace 'MySecurityNamespace'
            $result.Allow.Action | Should -Contain 'Read'
            $result.Deny | Should -BeNullOrEmpty
            $result.DescriptorType | Should -Be 'MySecurityNamespace'
        }

        It 'Should return ACE with Deny action' {
            $result = Format-ACEs -Allow 0 -Deny 2 -SecurityNamespace 'MySecurityNamespace'
            $result.Allow | Should -BeNullOrEmpty
            $result.Deny.Action | Should -Contain 'Write'
            $result.DescriptorType | Should -Be 'MySecurityNamespace'
        }

        It 'Should return ACE with both Allow and Deny actions' {
            $result = Format-ACEs -Allow 1 -Deny 2 -SecurityNamespace 'MySecurityNamespace'
            $result.Allow.Action | Should -Contain 'Read'
            $result.Deny.Action | Should -Contain 'Write'
            $result.DescriptorType | Should -Be 'MySecurityNamespace'
        }

        It 'Should return empty ACE if neither Allow nor Deny actions are specified' {
            $result = Format-ACEs -Allow 0 -Deny 0 -SecurityNamespace 'MySecurityNamespace'
            $result.Allow | Should -BeNullOrEmpty
            $result.Deny | Should -BeNullOrEmpty
            $result.DescriptorType | Should -Be 'MySecurityNamespace'
        }
    }

    Describe 'Parameter Validation' {
        It 'Should throw an error if SecurityNamespace is not provided' {
            { Format-ACEs -Allow 1 -Deny 0 } | Should -Throw
        }

        It 'Should allow only integer values for Allow and Deny parameters' {
            { Format-ACEs -Allow 'string' -Deny 0 -SecurityNamespace 'MySecurityNamespace' } | Should -Throw
            { Format-ACEs -Allow 1 -Deny 'string' -SecurityNamespace 'MySecurityNamespace' } | Should -Throw
        }
    }
}

