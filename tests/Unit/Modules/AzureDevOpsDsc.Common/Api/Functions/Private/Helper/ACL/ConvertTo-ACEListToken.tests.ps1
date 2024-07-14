powershell
Describe "ConvertTo-ACETokenList Tests" {
    
    Mock Get-CacheItem

    Context "When Security Descriptor is not found" {
        It "Should return an error message" {
            Get-CacheItem -Key "SecurityNamespace" -Type 'SecurityNamespaces' | Mock -MockWith { $null }

            { ConvertTo-ACETokenList -SecurityNamespace "SecurityNamespace" -ACEPermissions @(@{}) } | Should -Throw -ErrorId "Security Descriptor not found for namespace: SecurityNamespace"
        }
    }

    Context "When Security Descriptor is found" {
        $mockedDescriptor = @{
            'actions' = @(
                @{
                    'displayName' = 'read'
                    'name'        = 'read'
                },
                @{
                    'displayName' = 'write'
                    'name'        = 'write'
                }
            )
        }

        Mock Get-CacheItem -MockWith { return $mockedDescriptor }

        It "Should process ACE Permissions correctly" {
            $ACEPermissions = @(
                @{ 'read' = 'Allow'; 'write' = 'Deny' }
            )

            $result = ConvertTo-ACETokenList -SecurityNamespace "SecurityNamespace" -ACEPermissions $ACEPermissions

            $result | Should -Not -BeNullOrEmpty
            $result[0].DescriptorType | Should -Be "SecurityNamespace"
            $result[0].Allow.displayName | Should -Contain "read"
            $result[0].Deny.displayName  | Should -Contain "write"
        }

        It "Should handle missing permissions correctly" {
            $ACEPermissions = @(
                @{ 'execute' = 'Allow' }
            )

            { ConvertTo-ACETokenList -SecurityNamespace "SecurityNamespace" -ACEPermissions $ACEPermissions } | Should -Not -Throw
        }
    }
}

