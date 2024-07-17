# Import the module containing the New-xAzDoGroupPermission function

# Mocking external dependencies
Mock Get-CacheItem {
    param (
        [string]$Key,
        [string]$Type
    )
    if ($Type -eq 'SecurityNamespaces') {
        return @{
            namespaceId = 'namespace-id'
        }
    } elseif ($Type -eq 'LiveProjects') {
        return @{
            id = 'project-id'
        }
    } elseif ($Type -eq 'LiveGroups') {
        return @{
            id = 'group-id'
        }
    } elseif ($Type -eq 'LiveACLList') {
        return @('acl1', 'acl2')
    }
}

Mock ConvertTo-ACLHashtable {
    param (
        [array]$ReferenceACLs,
        [array]$DescriptorACLList,
        [string]$DescriptorMatchToken
    )
    return @{
        aces = @('ace1', 'ace2')
    }
}

Mock Set-xAzDoPermission {
    param (
        [string]$OrganizationName,
        [string]$SecurityNamespaceID,
        [HashTable]$SerializedACLs
    )
    # No-op for mocking purposes
}

# Describe block for New-xAzDoGroupPermission tests
Describe 'New-xAzDoGroupPermission Tests' {

    # Test case to check mandatory parameters
    Context 'Mandatory Parameters' {
        It 'Should throw an error when GroupName is missing' {
            { New-xAzDoGroupPermission -isInherited $true } | Should -Throw
        }

        It 'Should throw an error when isInherited is missing' {
            { New-xAzDoGroupPermission -GroupName 'Project\Group' } | Should -Throw
        }
    }

    # Test case to check verbose output
    Context 'Verbose Output' {
        It 'Should output verbose messages' {
            $verboseOutput = & {
                $VerbosePreference = 'Continue'
                New-xAzDoGroupPermission -GroupName 'Project\Group' -isInherited $true -Verbose
            } 4>&1

            $verboseOutput | Should -Contain '[New-xAzDoProjectGroupPermission] Started.'
        }
    }

    # Test case for key functionality
    Context 'Functionality' {
        It 'Should set the correct Git repository permissions' {
            $LookupResult = @{
                propertiesChanged = @('property1', 'property2')
            }

            $params = @{
                OrganizationName = 'OrgName'
                SecurityNamespaceID = 'namespace-id'
                SerializedACLs = @{
                    aces = @('ace1', 'ace2')
                }
            }

            Mock Set-xAzDoPermission {
                param (
                    [string]$OrganizationName,
                    [string]$SecurityNamespaceID,
                    [HashTable]$SerializedACLs
                )
                $OrganizationName | Should -Be 'OrgName'
                $SecurityNamespaceID | Should -Be 'namespace-id'
                $SerializedACLs.aces.Count | Should -Be 2
            }

            New-xAzDoGroupPermission -GroupName 'Project\Group' -isInherited $true -LookupResult $LookupResult
        }
    }
}
