
Describe 'AzDoAPI_5_PermissionsCache' {
    Mock -CommandName 'List-DevOpsSecurityNamespaces' {
        return @(
            [PSCustomObject]@{
                namespaceId = '12345'
                name = 'Namespace1'
                displayName = 'Namespace 1'
                writePermission = $true
                readPermision = $false
                dataspaceCategory = 'Category1'
                actions = @('Read', 'Write')
            }
            [PSCustomObject]@{
                namespaceId = '67890'
                name = 'Namespace2'
                displayName = 'Namespace 2'
                writePermission = $false
                readPermision = $true
                dataspaceCategory = 'Category2'
                actions = @('Delete', 'Create')
            }
        )
    }

    Mock -CommandName 'Add-CacheItem'
    Mock -CommandName 'Export-CacheObject'

    Context 'When organization name is provided' {
        It 'should list security namespaces and add them to cache' {
            AzDoAPI_5_PermissionsCache -OrganizationName 'TestOrg'

            Should -InvokeCommand 'List-DevOpsSecurityNamespaces' -Times 1 -Exactly -Scope It
            Should -InvokeCommand 'Add-CacheItem' -Times 2 -Exactly -Scope It
            Should -InvokeCommand 'Export-CacheObject' -Times 1 -Exactly -Scope It
        }
    }

    Context 'When organization name is not provided' {
        BeforeAll {
            # Set the global variable for organization name
            $Global:DSCAZDO_OrganizationName = 'GlobalTestOrg'
        }

        It 'should use the global variable for organization name' {
            AzDoAPI_5_PermissionsCache

            Should -InvokeCommand 'List-DevOpsSecurityNamespaces' -Times 1 -Exactly -Scope It
            Should -InvokeCommand 'Add-CacheItem' -Times 2 -Exactly -Scope It
            Should -InvokeCommand 'Export-CacheObject' -Times 1 -Exactly -Scope It
        }
    }
}

