$currentFile = $MyInvocation.MyCommand.Path

Describe "AzDoAPI_4_GitRepositoryCache Tests" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-CacheObject
        Mock -CommandName List-DevOpsGitRepository
        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

    }

    Context "When \ is passed" {
        It "Should call Get-CacheObject with LiveProjects" {
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled -CommandName Get-CacheObject -Exactly -Times 1 -ParameterFilter { $CacheType -eq 'LiveProjects' }
        }

        It "Should call List-DevOpsGitRepository for each project" {
            $mockProjects = @(
                [PSCustomObject]@{ Value = @{ Name = "TestProject1" } },
                [PSCustomObject]@{ Value = @{ Name = "TestProject2" } }
            )
            Mock -CommandName Get-CacheObject -MockWith { $mockProjects }
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled -CommandName List-DevOpsGitRepository -Exactly -Times 2
        }

        It "Should call Add-CacheItem for each repository" {
            $mockProjects = @(
                [PSCustomObject]@{ Value = @{ Name = "TestProject1" } },
                [PSCustomObject]@{ Value = @{ Name = "TestProject2" } }
            )
            $mockRepos = @(
                [PSCustomObject]@{ Name = "Repo1" },
                [PSCustomObject]@{ Name = "Repo2" }
            )
            Mock -CommandName Get-CacheObject -MockWith { $mockProjects }
            Mock -CommandName List-DevOpsGitRepository -MockWith { $mockRepos }
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 4
        }

        It "Should call Export-CacheObject once" {
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg"
            Assert-MockCalled -CommandName Export-CacheObject -Exactly -Times 1
        }

        It "Should log verbose messages" {
            $ProgressPreference='SilentlyContinue'
            Mock -CommandName Write-Verbose -Verifiable
            AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg" -Verbose
        }

        It "Should catch and log errors" {
            Mock -CommandName Write-Error -Verifiable
            Mock -CommandName List-DevOpsGitRepository -MockWith { throw "Mocked Error" }
            { AzDoAPI_4_GitRepositoryCache -OrganizationName "TestOrg" } | Should -Not -Throw
        }
    }

    Context "When \ is not passed" {
        BeforeAll { $Global:DSCAZDO_OrganizationName = "GlobalOrg" }

        It "Should use global variable for organization name" {
            $mockProjects = @(
                [PSCustomObject]@{ Value = @{ Name = "TestProject1" } },
                [PSCustomObject]@{ Value = @{ Name = "TestProject2" } }
            )
            $mockRepos = @(
                [PSCustomObject]@{ Name = "Repo1" },
                [PSCustomObject]@{ Name = "Repo2" }
            )

            Mock -CommandName Get-CacheObject -MockWith { $mockProjects }
            Mock -CommandName List-DevOpsGitRepository -MockWith { $mockRepos }

            AzDoAPI_4_GitRepositoryCache
            Assert-MockCalled -CommandName List-DevOpsGitRepository -Times 1 -ParameterFilter { $OrganizationName -eq "GlobalOrg" }

        }

        AfterAll { Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global }
    }
}
