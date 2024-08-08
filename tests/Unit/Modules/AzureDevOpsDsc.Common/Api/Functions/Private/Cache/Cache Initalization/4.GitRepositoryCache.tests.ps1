Describe "AzDoAPI_4_GitRepositoryCache Tests" {
    Mock -CommandName Get-CacheObject
    Mock -CommandName List-DevOpsGitRepository
    Mock -CommandName Add-CacheItem
    Mock -CommandName Export-CacheObject

    Context "When $OrganizationName is passed" {
        It "Should call Get-CacheObject with LiveProjects" {
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled Get-CacheObject -Exactly -Times 1 -ParameterFilter { $CacheType -eq 'LiveProjects' }
        }

        It "Should call List-DevOpsGitRepository for each project" {
            $mockProjects = @{ Value = @{ Name = "TestProject1" }; Value = @{ Name = "TestProject2" } }
            Mock Get-CacheObject { $mockProjects }
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled List-DevOpsGitRepository -Exactly -Times 2
        }

        It "Should call Add-CacheItem for each repository" {
            $mockProjects = @{ Value = @{ Name = "TestProject1" }; Value = @{ Name = "TestProject2" } }
            $mockRepos = @( @{ Name = "Repo1" }, @{ Name = "Repo2" } )
            Mock Get-CacheObject { $mockProjects }
            Mock List-DevOpsGitRepository { $mockRepos }
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled Add-CacheItem -Exactly -Times 4
        }

        It "Should call Export-CacheObject once" {
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled Export-CacheObject -Exactly -Times 1
        }

        It "Should log verbose messages" {
            $verbose = $false
            $ProgressPreference='SilentlyContinue'
            Mock Write-Verbose { param($Message); $verbose = $true }
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg" -Verbose
            $verbose | Should -Be $true
        }

        It "Should catch and log errors" {
            Mock List-DevOpsGitRepository { throw "Mocked Error" }
            $errorLogged = $false
            Mock Write-Error { $errorLogged = $true }
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            $errorLogged | Should -Be $true
        }
    }

    Context "When $OrganizationName is not passed" {
        BeforeAll { $Global:DSCAZDO_OrganizationName = "GlobalOrg" }

        It "Should use global variable for organization name" {
            $usedGlobal = $false
            Mock List-DevOpsGitRepository { param ($ProjectName, $OrganizationName); if ($OrganizationName -eq "GlobalOrg") { $usedGlobal = $true }; return @() }
            AzDoAPI_4_GitRepositoryCache
            $usedGlobal | Should -Be $true
        }

        AfterAll { Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global }
    }
}

