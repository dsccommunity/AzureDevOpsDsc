# Requires -Module Pester -Version 5.0.0
# Requires -Module DscResource.Common

# Test if the class is defined
if ($Global:ClassesLoaded -eq $null)
{
    # Attempt to find the root of the repository
    $RepositoryRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.Parent.Parent.FullName
    # Load the classes
    $preInitialize = Get-ChildItem -Path "$RepositoryRoot" -Recurse -Filter '*.ps1' | Where-Object { $_.Name -eq 'Classes.BeforeAll.ps1' }
    . $preInitialize.FullName -RepositoryPath $RepositoryRoot
}

Describe 'xAzDoGitRepository' {
    BeforeAll {
        # Mock functions that interact with external resources
        function Get-xAzDoGitRepository
        {
            param (
                [string]$ProjectName,
                [string]$GitRepositoryName
            )
            # Return a mock object representing the current state
            return @{
                ProjectName = $ProjectName
                GitRepositoryName = $GitRepositoryName
                SourceRepository = 'https://github.com/MyUser/MyRepository.git'
                Ensure = 'Present'
            }
        }

        function New-xAzDoGitRepository
        {
            param (
                [string]$ProjectName,
                [string]$GitRepositoryName,
                [string]$SourceRepository,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "New Git repository created: $ProjectName/$GitRepositoryName"
        }

        function Update-xAzDoGitRepository
        {
            param (
                [string]$ProjectName,
                [string]$GitRepositoryName,
                [string]$SourceRepository,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Git repository updated: $ProjectName/$GitRepositoryName"
        }

        function Remove-xAzDoGitRepository
        {
            param (
                [string]$ProjectName,
                [string]$GitRepositoryName,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Git repository removed: $ProjectName/$GitRepositoryName"
        }
    }

    Context 'When getting the current state of a Git repository' {
        It 'Should return the current state properties' {
            # Arrange
            $gitRepository = [xAzDoGitRepository]::new()
            $gitRepository.ProjectName = "MyProject"
            $gitRepository.RepositoryName = "MyRepository"

            # Act
            $currentState = $gitRepository.Get()

            # Assert
            $currentState.ProjectName | Should -Be "MyProject"
            $currentState.GitRepositoryName | Should -Be "MyRepository"
            $currentState.SourceRepository | Should -Be 'https://github.com/MyUser/MyRepository.git'
        }
    }
}
