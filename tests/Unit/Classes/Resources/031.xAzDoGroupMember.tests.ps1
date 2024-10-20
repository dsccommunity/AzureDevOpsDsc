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

Describe 'xAzDoGroupMember' {
    BeforeAll {
        # Mock functions that interact with external resources
        function Get-xAzDoGroupMember
        {
            param (
                [string]$GroupName,
                [string[]]$GroupMembers
            )
            # Return a mock object representing the current state
            return @{
                GroupName = $GroupName
                GroupMembers = $GroupMembers
                Ensure = 'Present'
            }
        }

        function New-xAzDoGroupMember
        {
            param (
                [string]$GroupName,
                [string[]]$GroupMembers,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "New group member added to: $GroupName"
        }

        function Update-xAzDoGroupMember
        {
            param (
                [string]$GroupName,
                [string[]]$GroupMembers,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Group members updated in: $GroupName"
        }

        function Remove-xAzDoGroupMember
        {
            param (
                [string]$GroupName,
                [string]$Pat,
                [string]$ApiUri
            )
            # Mock implementation
            Write-Output "Group members removed from: $GroupName"
        }
    }

    Context 'When getting the current state of group members' {
        It 'Should return the current state properties' {
            # Arrange
            $groupMember = [xAzDoGroupMember]::new()
            $groupMember.GroupName = "MyGroup"
            $groupMember.GroupMembers = @("User1", "User2")

            # Act
            $currentState = $groupMember.Get()

            # Assert
            $currentState.GroupName | Should -Be "MyGroup"
            $currentState.GroupMembers | Should -Be @("User1", "User2")
        }
    }
}
