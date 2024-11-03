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

Describe "AzDoProject Class" {

    BeforeAll {

        $ENV:AZDODSC_CACHE_DIRECTORY = 'mocked_cache_directory'

        $TestProjectNameFunctionpath = Get-FunctionItem 'Test-AzDevOpsProjectName.ps1'
        . $TestProjectNameFunctionpath

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
        Mock -CommandName Test-AzDevOpsProjectName -MockWith { return $true }

    }

    Context "Initialization" {
        It "Should initialize with default values" {
            $project = [AzDoProject]::new()

            # Validate default values
            $project.SourceControlType | Should -Be 'Git'
            $project.ProcessTemplate   | Should -Be 'Agile'
            $project.Visibility        | Should -Be 'Private'
        }
    }

    Context "Property Assignment" {
        It "Should allow setting ProjectName and ProjectDescription" {
            $project = [AzDoProject]::new()
            $project.ProjectName = 'TestProject'
            $project.ProjectDescription = 'This is a test project'

            # Validate assigned values
            $project.ProjectName | Should -Be 'TestProject'
            $project.ProjectDescription | Should -Be 'This is a test project'
        }

        It "Should validate SourceControlType" {
            $project = [AzDoProject]::new()

            # Valid value
            { $project.SourceControlType = 'Tfvc' } | Should -Not -Throw

            # Invalid value
            { $project.SourceControlType = 'InvalidValue' } | Should -Throw
        }

        It "Should validate ProcessTemplate" {
            $project = [AzDoProject]::new()

            # Valid value
            { $project.ProcessTemplate = 'Scrum' } | Should -Not -Throw

            # Invalid value
            { $project.ProcessTemplate = 'InvalidValue' } | Should -Throw
        }

        It "Should validate Visibility" {
            $project = [AzDoProject]::new()

            # Valid value
            { $project.Visibility = 'Public' } | Should -Not -Throw

            # Invalid value
            { $project.Visibility = 'InvalidValue' } | Should -Throw
        }
    }

    Context "Get Method" {
        It "Should return an instance of AzDoProject" {

            Mock -CommandName Test-AzDevOpsProjectName -MockWith { return $true }
            Mock -CommandName Get-AzDoProject -MockWith {
                return @{
                    Ensure             = [Ensure]::Absent
                    ProjectName        = 'MyProject'
                    ProjectDescription = 'This is a sample project'
                    SourceControlType  = 'Git'
                    ProcessTemplate    = 'Agile'
                    Visibility         = 'Private'
                    propertiesChanged  = @()
                    status             = $null
                }
            }

            $project = [AzDoProject]::new()
            $project.ProjectName = 'MyProject'
            $result = $project.Get()

            $result | Should -BeOfType 'AzDoProject'
        }
    }
}
