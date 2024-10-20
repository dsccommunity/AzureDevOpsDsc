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

Describe 'xAzDoProjectGroup' {
    BeforeAll {
        # Mock functions that interact with external resources
        function Get-xAzDoProjectGroup
        {
            param (
                [string]$GroupName,
                [string]$GroupDescription,
                [string]$ProjectName
            )
            # Return a mock object representing the current state
            return @{
                GroupName = $GroupName
                GroupDescription = $GroupDescription
                ProjectName = $ProjectName
                Ensure = 'Present'
            }
        }

        function New-xAzDoProjectGroup
        {
            param (
                [string]$ProjectName,
                [string]$GroupName,
                [string]$GroupDescription,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "New project group created: $GroupName in project $ProjectName"
        }

        function Update-xAzDoProjectGroup
        {
            param (
                [string]$ProjectName,
                [string]$GroupName,
                [string]$GroupDescription,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Project group updated: $GroupName in project $ProjectName"
        }

        function Remove-xAzDoProjectGroup
        {
            param (
                [string]$ProjectName,
                [string]$GroupName,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Project group removed: $GroupName in project $ProjectName"
        }
    }

    Context 'When getting the current state of a project group' {
        It 'Should return the current state properties' {
            # Arrange
            $projectGroup = [xAzDoProjectGroup]::new()
            $projectGroup.ProjectName = "MyProject"
            $projectGroup.GroupName = "MyGroup"
            $projectGroup.GroupDescription = "This is my project group."

            # Act
            $currentState = $projectGroup.Get()

            # Assert
            $currentState.GroupName | Should -Be "MyGroup"
            $currentState.ProjectName | Should -Be "MyProject"
            $currentState.GroupDescription | Should -Be "This is my project group."
        }
    }
}
