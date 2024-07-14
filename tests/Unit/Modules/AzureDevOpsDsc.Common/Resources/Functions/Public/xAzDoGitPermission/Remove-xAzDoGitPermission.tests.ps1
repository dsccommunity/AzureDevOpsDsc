
Describe "Remove-xAzDoGitPermission" {
    Mock -ModuleName 'ModuleName' -Name 'Get-CacheItem'
    Mock -ModuleName 'ModuleName' -Name 'Remove-GitRepositoryPermission'

    $Global:DSCAZDO_OrganizationName = 'TestOrg'

    BeforeEach {
        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepo'
        $isInherited = $false
        $Permissions = @()
        $LookupResult = @{}
        $Ensure = 'Present'
        $Force = $false

        Mock Get-CacheItem -MockWith {
            switch ($args[1]) {
                'SecurityNamespaces' { @{ namespaceId = 'namespaceIdValue' } }
                'LiveProjects' { @{ id = 'projectIdValue' } }
                'LiveRepositories' { @{ id = 'repositoryIdValue' } }
                'LiveACLList' { @(@{ token = 'repoV2/projectIdValue/repositoryIdValue' }) }
                default { $null }
            }
        }
    }

    It "Removes ACLs if Filtered is not null" {
        Remove-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions -LookupResult $LookupResult -Ensure $Ensure -Force:$Force

        Should -Invoke -CommandName 'Remove-GitRepositoryPermission' -With {
            param (
                [string]$OrganizationName,
                [string]$SecurityNamespaceID,
                [string]$TokenName
            )
            ($OrganizationName -eq 'TestOrg') -and
            ($SecurityNamespaceID -eq 'namespaceIdValue') -and
            ($TokenName -eq 'repoV2/projectIdValue/repositoryIdValue')
        }
    }

    It "Does not call Remove-GitRepositoryPermission if Filtered is null" {
        Mock Get-CacheItem -MockWith {
            switch ($args[1]) {
                'LiveACLList' { @(@{ token = 'repoV2/notMatchingValue' }) }
                default { $null }
            }
        }

        Remove-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions -LookupResult $LookupResult -Ensure $Ensure -Force:$Force

        Should -Not -Invoke -CommandName 'Remove-GitRepositoryPermission'
    }
}

