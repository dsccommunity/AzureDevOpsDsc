
Describe 'Set-xAzDoGitPermission' {
    Mock -CommandName Get-CacheItem
    Mock -CommandName ConvertTo-ACLHashtable
    Mock -CommandName Set-GitRepositoryPermission

    $ProjectName = 'TestProject'
    $RepositoryName = 'TestRepo'
    $isInherited = $true
    $Permissions = @(@{ User = 'TestUser'; Permission = 'Allow' })
    $LookupResult = @{ propertiesChanged = 'someValue' }
    $Ensure = [Ensure]::Present

    $Global:DSCAZDO_OrganizationName = 'TestOrg'

    BeforeEach {
        Mock -CommandName Get-CacheItem -MockWith {
            return @{
                namespaceId = 'SampleNamespaceId'
            }
        }
        Mock -CommandName ConvertTo-ACLHashtable -MockWith {
            return 'SerializedACLs'
        }
        Mock -CommandName Set-GitRepositoryPermission -MockWith {
            return $null
        }
    }

    It 'Calls Get-CacheItem with the correct parameters for security namespace' {
        Set-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions -LookupResult $LookupResult -Ensure $Ensure
        Assert-MockCalled Get-CacheItem -Exactly 1 -ParameterFilter { $_.Key -eq 'Git Repositories' -and $_.Type -eq 'SecurityNamespaces' }
    }

    It 'Calls Get-CacheItem with the correct parameters for the project' {
        Set-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions -LookupResult $LookupResult -Ensure $Ensure
        Assert-MockCalled Get-CacheItem -Exactly 1 -ParameterFilter { $_.Key -eq $ProjectName -and $_.Type -eq 'LiveProjects' }
    }

    It 'Calls Set-GitRepositoryPermission with the correct parameters' {
        Set-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions -LookupResult $LookupResult -Ensure $Ensure
        Assert-MockCalled Set-GitRepositoryPermission -Exactly 1 -ParameterFilter {
            $_.OrganizationName -eq 'TestOrg' -and
            $_.SecurityNamespaceID -eq 'SampleNamespaceId' -and
            $_.SerializedACLs -eq 'SerializedACLs'
        }
    }

    It 'Serializes ACLs using ConvertTo-ACLHashtable with correct parameters' {
        Set-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions -LookupResult $LookupResult -Ensure $Ensure
        Assert-MockCalled ConvertTo-ACLHashtable -Exactly 1 -ParameterFilter {
            $_.ReferenceACLs -eq 'someValue'
        }
    }
}

