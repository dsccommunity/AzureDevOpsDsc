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

Describe 'xAzDoGitPermission' {
    BeforeAll {
        # Mock functions that interact with external resources
        function Get-xAzDoGitPermission
        {
            param (
                [string]$ProjectName,
                [string]$RepositoryName
            )
            # Return a mock object representing the current state
            return @{
                ProjectName = $ProjectName
                RepositoryName = $RepositoryName
                isInherited = $true
                Permissions = @('Read', 'Contribute')
                Ensure = 'Present'
            }
        }

        function New-xAzDoGitPermission
        {
            param (
                [string]$ProjectName,
                [string]$RepositoryName,
                [boolean]$isInherited,
                [hashtable[]]$Permissions,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "New Git permissions set for: $ProjectName/$RepositoryName"
        }

        function Update-xAzDoGitPermission
        {
            param (
                [string]$ProjectName,
                [string]$RepositoryName,
                [boolean]$isInherited,
                [hashtable[]]$Permissions,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Git permissions updated for: $ProjectName/$RepositoryName"
        }

        function Remove-xAzDoGitPermission
        {
            param (
                [string]$ProjectName,
                [string]$RepositoryName,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Git permissions removed from: $ProjectName/$RepositoryName"
        }
    }

    Context 'When getting the current state of Git permissions' {
        It 'Should return the current state properties' {
            # Arrange
            $gitPermission = [xAzDoGitPermission]::new()
            $gitPermission.ProjectName = "MyProject"
            $gitPermission.RepositoryName = "MyRepository"

            # Act
            $currentState = $gitPermission.Get()

            # Assert
            $currentState.ProjectName | Should -Be "MyProject"
            $currentState.RepositoryName | Should -Be "MyRepository"
            $currentState.isInherited | Should -Be $true
            $currentState.Permissions | Should -Be @('Read', 'Contribute')
        }
    }
}
