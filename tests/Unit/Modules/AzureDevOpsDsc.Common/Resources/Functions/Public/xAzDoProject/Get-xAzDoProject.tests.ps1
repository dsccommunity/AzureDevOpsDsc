$currentFile = $MyInvocation.MyCommand.Path
# Pester tests for Get-xAzDoProject

Describe "Get-xAzDoProject" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-xAzDoOrganizationGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')

        # Define common mock responses
        $mockProject = @{
            ProjectName       = 'ExistingProject'
            description       = 'ExistingDescription'
            SourceControlType = 'Git'
            Visibility        = 'Private'
        }

        $mockProcessTemplate = @{
            ProcessTemplate = 'Agile'
        }

        Mock -CommandName Test-AzDevOpsProjectName -MockWith { return $true }
        Mock -CommandName Write-Warning

    }

    Context "when the project exists" {
        BeforeEach {
            # Mock Get-CacheItem to return an existing project
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'ExistingProject' -and $Type -eq 'LiveProjects' } -MockWith { return $mockProject }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'Agile' -and $Type -eq 'LiveProcesses' } -MockWith { return $mockProcessTemplate }
        }

        It "should return the project details with status unchanged" {
            $result = Get-xAzDoProject -ProjectName 'ExistingProject' -ProjectDescription 'ExistingDescription' -SourceControlType 'Git' -ProcessTemplate 'Agile' -Visibility 'Private'
            $result.Status | Should -BeNullOrEmpty
            $result.ProjectName | Should -Be 'ExistingProject'
            $result.ProjectDescription | Should -Be 'ExistingDescription'
        }

        It "should return status changed when descriptions differ" {
            $result = Get-xAzDoProject -ProjectName 'ExistingProject' -ProjectDescription 'NewDescription' -SourceControlType 'Git' -ProcessTemplate 'Agile' -Visibility 'Private'
            $result.Status | Should -Be 'Changed'
            $result.propertiesChanged | Should -Contain 'Description'
        }

        It "should return status changed when visibility differs" {
            $result = Get-xAzDoProject -ProjectName 'ExistingProject' -ProjectDescription 'ExistingDescription' -SourceControlType 'Git' -ProcessTemplate 'Agile' -Visibility 'Public'
            $result.Status | Should -Be 'Changed'
            $result.propertiesChanged | Should -Contain 'Visibility'
        }
    }

    Context "when the project does not exist" {
        BeforeEach {
            # Mock Get-CacheItem to return null for non-existing project
            Mock -CommandName Get-CacheItem -ParameterFilter { $true } -MockWith { return $null }
        }

        It "should return status NotFound" {
            $result = Get-xAzDoProject -ProjectName 'NonExistentProject' -ProjectDescription 'AnyDescription' -SourceControlType 'Git' -ProcessTemplate 'Agile' -Visibility 'Private'
            $result.Status | Should -Be 'NotFound'
        }
    }

    Context "when the process template does not exist" {
        BeforeEach {
            # Mock Get-CacheItem to return null for non-existing process template
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'ExistingProject' -and $Type -eq 'LiveProjects' } -MockWith { return $mockProject }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'NonExistentTemplate' -and $Type -eq 'LiveProcesses' } -MockWith { return $null }
        }

        It "should throw an error" {
            { Get-xAzDoProject -ProjectName 'ExistingProject' -ProjectDescription 'ExistingDescription' -SourceControlType 'Git' -ProcessTemplate 'NonExistentTemplate' -Visibility 'Private' } | Should -Throw
        }
    }

    Context "when source control type differs" {
        BeforeEach {
            # Mock Get-CacheItem to return an existing project with different source control type
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'ExistingProject' -and $Type -eq 'LiveProjects' } -MockWith {
                $mockProject.SourceControlType = 'Tfvc'
                return $mockProject
            }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'Agile' -and $Type -eq 'LiveProcesses' } -MockWith { return $mockProcessTemplate }
        }

        It "should warn about source control type conflict" {
            $result = Get-xAzDoProject -ProjectName 'ExistingProject' -ProjectDescription 'ExistingDescription' -SourceControlType 'Git' -ProcessTemplate 'Agile' -Visibility 'Private'
            $result.Status | Should -BeNullOrEmpty
            $result.ProjectName | Should -Be 'ExistingProject'
            $result.SourceControlType | Should -Be 'Git'
        }
    }
}
