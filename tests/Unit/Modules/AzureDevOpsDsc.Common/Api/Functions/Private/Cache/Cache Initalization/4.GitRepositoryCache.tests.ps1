powershell
Describe "AzDoAPI_4_GitRepositoryCache Unit Tests" {
    Mock Get-CacheObject {
        return @(
            @{ Key = '1'; Value = @{ Name = 'Project1' } },
            @{ Key = '2'; Value = @{ Name = 'Project2' } }
        )
    }

    Mock List-DevOpsGitRepository {
        param ($ProjectName, $OrganizationName)
        switch ($ProjectName) {
            'Project1' { return @(@{ Name = 'Repo1' }, @{ Name = 'Repo2' }) }
            'Project2' { return @(@{ Name = 'Repo3' }) }
        }
    }

    Mock Add-CacheItem {}
    Mock Export-CacheObject {}

    $script:global:DSCAZDO_OrganizationName = 'GlobalOrg'

    BeforeEach {
        Clear-Mock
    }

    It "Uses global variable for organization name when parameter is not provided" {
        AzDoAPI_4_GitRepositoryCache

        Assert-MockCalled -CommandName Get-CacheObject -Exactly -Times 1
        Assert-MockCalled -CommandName List-DevOpsGitRepository -Exactly -Times 2 -Scope It -Parameters @(
            @{ ProjectName = 'Project1'; OrganizationName = 'GlobalOrg' },
            @{ ProjectName = 'Project2'; OrganizationName = 'GlobalOrg' }
        )
        Assert-MockCalled -CommandName Export-CacheObject -Exactly -Times 1
    }

    It "Uses provided organization name as parameter" {
        AzDoAPI_4_GitRepositoryCache -OrganizationName 'ParamOrg'

        Assert-MockCalled -CommandName List-DevOpsGitRepository -Exactly -Times 2 -Scope It -Parameters @(
            @{ ProjectName = 'Project1'; OrganizationName = 'ParamOrg' },
            @{ ProjectName = 'Project2'; OrganizationName = 'ParamOrg' }
        )
    }

    It "Adds repositories to cache" {
        AzDoAPI_4_GitRepositoryCache -OrganizationName 'TestOrg'

        Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 3 -Scope It -Parameters @(
            @{ Key = 'Project1\Repo1'; Value = @{ Name = 'Repo1' }; Type = 'LiveRepositories' },
            @{ Key = 'Project1\Repo2'; Value = @{ Name = 'Repo2' }; Type = 'LiveRepositories' },
            @{ Key = 'Project2\Repo3'; Value = @{ Name = 'Repo3' }; Type = 'LiveRepositories' }
        )
    }

    It "Handles errors gracefully" {
        Mock List-DevOpsGitRepository { throw "API error" }

        { AzDoAPI_4_GitRepositoryCache -OrganizationName 'ErrorOrg' } | Should -Throw
    }
}

