
Describe 'Get-xAzDoGitPermission Tests' {
    BeforeAll {
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
        Function Mock-Get-CacheItem {
            param (
                [string]$Key,
                [string]$Type
            )
            switch ($Type) {
                'LiveRepositories' { return @{ id = 123; Name = "TestRepository" } }
                'SecurityNamespaces' { return @{ namespaceId = "TestNamespaceId" } }
                default { return $null }
            }
        }

        Function Mock-Get-DevOpsACL {
            param (
                [Parameter(Mandatory)]
                [string]$OrganizationName,
                [Parameter(Mandatory)]
                [string]$SecurityDescriptorId
            )
            return @( @{ Token = @{ Type = 'GitRepository'; RepoId = 123 }; Permission = 'Allow' } )
        }

        Function Mock-ConvertTo-FormattedACL {
            param (
                [Parameter(Mandatory)]
                $SecurityNamespace,
                [Parameter(Mandatory)]
                $OrganizationName
            )
            return @( @{ Token = @{ Type = 'GitRepository'; RepoId = 123 }; Permission = 'Allow' } )
        }

        Function Mock-ConvertTo-ACL {
            param (
                [Parameter(Mandatory)]
                $Permissions,
                [Parameter(Mandatory)]
                $SecurityNamespace,
                [Parameter(Mandatory)]
                $isInherited,
                [Parameter(Mandatory)]
                $OrganizationName,
                [Parameter(Mandatory)]
                $TokenName
            )
            return @( @{ Token = @{ Type = 'GitRepository'; RepoId = 123 }; Permission = 'Deny' } )
        }

        Function Mock-Test-ACLListforChanges {
            param (
                [Parameter(Mandatory)]
                $ReferenceACLs,
                [Parameter(Mandatory)]
                $DifferenceACLs
            )
            return @{
                propertiesChanged = @('Permission');
                status = 'Changed';
                reason = 'Permission mismatch'
            }
        }

        Mock Get-CacheItem { Mock-Get-CacheItem -Key $Key -Type $Type }
        Mock Get-DevOpsACL { Mock-Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId }
        Mock ConvertTo-FormattedACL { Mock-ConvertTo-FormattedACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName }
        Mock ConvertTo-ACL { Mock-ConvertTo-ACL -Permissions $Permissions -SecurityNamespace $SecurityNamespace -isInherited $isInherited -OrganizationName $OrganizationName -TokenName $TokenName }
        Mock Test-ACLListforChanges { Mock-Test-ACLListforChanges -ReferenceACLs $ReferenceACLs -DifferenceACLs $DifferenceACLs }
    }

    It 'Should retrieve repository and namespace, and compare ACLs correctly' {
        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepository'
        $isInherited = $true
        $Permissions = @(@{ 'Permission' = 'Deny' })

        $result = Get-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions

        $result | Should -Not -BeNullOrEmpty
        $result.status | Should -Be 'Changed'
        $result.reason | Should -Be 'Permission mismatch'
        $result.propertiesChanged | Should -Contain 'Permission'
    }
}

