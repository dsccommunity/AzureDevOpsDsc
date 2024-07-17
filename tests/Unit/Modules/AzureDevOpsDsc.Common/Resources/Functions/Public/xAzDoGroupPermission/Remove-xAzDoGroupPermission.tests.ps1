
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
    } elseif ($Type -eq 'LiveRepositories') {
        return @{
            id = 'repository-id'
        }
    } elseif ($Type -eq 'LiveACLList') {
        return @(
            @{ token = "repoV2/project-id/repository-id" },
            @{ token = "repoV2/other-project/other-repo" }
        )
    }
}

Mock Remove-xAzDoPermission {
    param (
        [string]$OrganizationName,
        [string]$SecurityNamespaceID,
        [string]$TokenName
    )
    # No-op for mocking purposes
}

# Describe block for Remove-xAzDoGroupPermission tests
Describe 'Remove-xAzDoGroupPermission Tests' {

    # Test case to check mandatory parameters
    Context 'Mandatory Parameters' {
        It 'Should throw an error when GroupName is missing' {
            { Remove-xAzDoGroupPermission -isInherited $true } | Should -Throw
        }

        It 'Should throw an error when isInherited is missing' {
            { Remove-xAzDoGroupPermission -GroupName 'Project\Group' } | Should -Throw
        }
    }

    # Test case to check verbose output
    Context 'Verbose Output' {
        It 'Should output verbose messages' {
            $verboseOutput = & {
                $VerbosePreference = 'Continue'
                Remove-xAzDoGroupPermission -GroupName 'Project\Group' -isInherited $true -Verbose
            } 4>&1

            $verboseOutput | Should -Contain '[New-xAzDoGitPermission] Started.'
        }
    }

    # Test case for key functionality
    Context 'Functionality' {
        It 'Should remove the correct Git repository permissions' {
            $params = @{
                OrganizationName = 'OrgName'
                SecurityNamespaceID = 'namespace-id'
                TokenName = 'repoV2/project-id/repository-id'
            }

            Mock Remove-xAzDoPermission {
                param (
                    [string]$OrganizationName,
                    [string]$SecurityNamespaceID,
                    [string]$TokenName
                )
                $OrganizationName | Should -Be 'OrgName'
                $SecurityNamespaceID | Should -Be 'namespace-id'
                $TokenName | Should -Be 'repoV2/project-id/repository-id'
            }

            Remove-xAzDoGroupPermission -GroupName 'Project\Group' -isInherited $true
        }

        It 'Should not call Remove-xAzDoPermission if no matching ACLs are found' {
            Mock Get-CacheItem {
                param (
                    [string]$Key,
                    [string]$Type
                )
                if ($Type -eq 'LiveACLList') {
                    return @(
                        @{ token = "repoV2/other-project/other-repo" }
                    )
                } else {
                    return $null
                }
            }

            Mock Remove-xAzDoPermission {
                # This should never be called
                throw "This should not be called"
            }

            { Remove-xAzDoGroupPermission -GroupName 'Project\Group' -isInherited $true } | Should -Not -Throw
        }
    }
}
