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

Describe 'AzDoProjectGroup' {

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

    Context 'When getting the current state of a project group' {

        BeforeAll {
            Mock -CommandName Get-AzDoProjectGroup -MockWith {
                return @{
                    Ensure = [Ensure]::Absent
                    propertiesChanged = @()
                    ProjectName = "MyProject"
                    GroupName = "MyGroup"
                    GroupDescription = "This is my project group."
                }
            }
        }

        It 'Should return the current state properties' {
            # Arrange
            $projectGroup = [AzDoProjectGroup]::new()
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
