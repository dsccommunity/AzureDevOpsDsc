# Requires -Module Pester -Version 5.0.0
# Requires -Module DscResource.Common

# Test if the class is defined
if ($null -eq $Global:ClassesLoaded)
{
    # Attempt to find the root of the repository
    $RepositoryRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.Parent.Parent.FullName
    # Load the Dependencies
    . "$RepositoryRoot\azuredevopsdsc.tests.ps1" -LoadModulesOnly
}

Describe 'AzDoGitRepository' {

    BeforeAll {
        $ENV:AZDODSC_CACHE_DIRECTORY = 'mocked_cache_directory'

        Mock -CommandName Import-Module
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Import-Clixml -MockWith {
            return @{
                OrganizationName = 'mock-org'
                Token = @{
                    tokenType = 'ManagedIdentity'
                    access_token = 'mock_access_token'
                }

            }
        }
        Mock -CommandName New-AzDoAuthenticationProvider
        Mock -CommandName Get-AzDoCacheObjects -MockWith {
            return @('mock-cache-type')
        }
        Mock -CommandName Initialize-CacheObject

    }
    AfterAll {

        $ENV:AZDODSC_CACHE_DIRECTORY = $null

    }


    Context 'When getting the current state of a Git repository' {

        BeforeAll {
            Mock -CommandName Get-AzDoGitRepository -MockWith {
                return @{
                    Ensure = [Ensure]::Absent
                    propertiesChanged = @()
                    ProjectName = "MyProject"
                    RepositoryName = "MyRepository"
                    SourceRepository = 'https://github.com/MyUser/MyRepository.git'
                }
            }
        }

        It 'Should return the current state properties' {
            # Arrange
            $gitRepository = [AzDoGitRepository]::new()
            $gitRepository.ProjectName = "MyProject"
            $gitRepository.RepositoryName = "MyRepository"

            # Act
            $currentState = $gitRepository.Get()

            # Assert
            $currentState.ProjectName | Should -Be "MyProject"
            $currentState.RepositoryName | Should -Be "MyRepository"
            $currentState.SourceRepository | Should -BeNullOrEmpty
            $currentState.LookupResult | Should -Not -BeNullOrEmpty
            $currentState.LookupResult.ProjectName | Should -Be "MyProject"
            $currentState.LookupResult.RepositoryName | Should -Be "MyRepository"
            $currentState.LookupResult.SourceRepository | Should -Be 'https://github.com/MyUser/MyRepository.git'
        }
    }
}
