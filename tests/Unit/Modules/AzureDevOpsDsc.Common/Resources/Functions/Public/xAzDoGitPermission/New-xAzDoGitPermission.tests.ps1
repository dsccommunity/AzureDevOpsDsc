powershell
Describe 'New-xAzDoGitPermission' {
    Mock Get-CacheItem
    Mock ConvertTo-ACLHashtable
    Mock Set-GitRepositoryPermission

    Context 'With mandatory parameters provided' {
        It 'should call Get-CacheItem for SecurityNamespace and Project' {
            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
            }
            New-xAzDoGitPermission @params

            Assert-MockCalled Get-CacheItem -Exactly 2 -Scope It
        }

        It 'should call ConvertTo-ACLHashtable and Set-GitRepositoryPermission' {
            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
                LookupResult = @{ propertiesChanged = @{} }
            }
            New-xAzDoGitPermission @params

            Assert-MockCalled ConvertTo-ACLHashtable -Exactly 1 -Scope It
            Assert-MockCalled Set-GitRepositoryPermission -Exactly 1 -Scope It
        }
    }

    Context 'With all parameters provided' {
        It 'should set permissions correctly' {
            $permissions = @(@{ Permission = 'Read'; Access = 'Allow' })

            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
                Permissions = $permissions
                LookupResult = @{ propertiesChanged = @{} }
                Ensure = 'Present'
                Force = $true
            }
            New-xAzDoGitPermission @params

            Assert-MockCalled Get-CacheItem -Exactly 2 -Scope It
            Assert-MockCalled ConvertTo-ACLHashtable -Exactly 1 -Scope It
            Assert-MockCalled Set-GitRepositoryPermission -Exactly 1 -Scope It
        }
    }
}

