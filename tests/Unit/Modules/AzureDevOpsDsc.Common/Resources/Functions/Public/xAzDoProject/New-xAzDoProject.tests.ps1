$currentFile = $MyInvocation.MyCommand.Path
# Pester tests for New-AzDoProject

Describe "New-AzDoProject" {


    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-AzDoProject.tests.ps1'
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
        $mockProcessTemplate = @{
            id = '12345'
            ProcessTemplate = 'Agile'
        }

        $mockProjectJob = @{
            url = 'https://dev.azure.com/TestOrg/_apis/projects/ExistingProject'
        }

        Mock -CommandName Test-AzDevOpsProjectName -MockWith { return $true }

    }

    Context "when parameters are valid" {
        BeforeEach {
            # Mock Get-CacheItem to return a process template
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'Agile' -and $Type -eq 'LiveProcesses' } -MockWith { return $mockProcessTemplate }

            # Mock New-DevOpsProject to simulate project creation
            Mock -CommandName New-DevOpsProject -MockWith { return $mockProjectJob }

            # Mock Wait-DevOpsProject to simulate waiting for project creation
            Mock -CommandName Wait-DevOpsProject

            # Mock AzDoAPI_0_ProjectCache to simulate cache refresh
            Mock -CommandName AzDoAPI_0_ProjectCache

        }

        It "should create a new project with specified parameters" {
            New-AzDoProject -ProjectName 'NewProject' -ProjectDescription 'New Project Description' -SourceControlType 'Git' -ProcessTemplate 'Agile' -Visibility 'Private'

            # Validate that Get-CacheItem was called with correct parameters
            Assert-MockCalled -CommandName Get-CacheItem -Exactly 1 -ParameterFilter { $Key -eq 'Agile' -and $Type -eq 'LiveProcesses' }

            # Validate that New-DevOpsProject was called with correct parameters
            Assert-MockCalled -CommandName New-DevOpsProject -Exactly 1 -ParameterFilter {
                ($organization -eq 'TestOrganization') -and
                ($projectName -eq 'NewProject') -and
                ($description -eq 'New Project Description') -and
                ($sourceControlType -eq 'Git') -and
                ($processTemplateId -eq '12345') -and
                ($visibility -eq 'Private')
            }

            # Validate that Wait-DevOpsProject was called with correct parameters
            Assert-MockCalled -CommandName Wait-DevOpsProject -Exactly 1 -ParameterFilter {
                $ProjectURL -eq 'https://dev.azure.com/TestOrg/_apis/projects/ExistingProject' -and
                $OrganizationName -eq 'TestOrganization'
            }

            # Validate that AzDoAPI_0_ProjectCache was called with correct parameters
            Assert-MockCalled -CommandName AzDoAPI_0_ProjectCache -Exactly 1 -ParameterFilter {
                $OrganizationName -eq 'TestOrganization'
            }
        }
    }

    Context "when process template does not exist" {
        BeforeEach {
            # Mock Get-CacheItem to return null for non-existing process template
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'NonExistentTemplate' -and $Type -eq 'LiveProcesses' } -MockWith { return $null }
        }

        It "should throw an error if process template is not found" {
            { New-AzDoProject -ProjectName 'NewProject' -ProjectDescription 'New Project Description' -SourceControlType 'Git' -ProcessTemplate 'NonExistentTemplate' -Visibility 'Private' } | Should -Throw
        }
    }

    Context "when force parameter is used" -skip {
        BeforeEach {
            # Mock Get-CacheItem to return a process template
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'Agile' -and $Type -eq 'LiveProcesses' } -MockWith { return $mockProcessTemplate }

            # Mock New-DevOpsProject to simulate project creation
            Mock -CommandName New-DevOpsProject -MockWith { return $mockProjectJob }

            # Mock Wait-DevOpsProject to simulate waiting for project creation
            Mock -CommandName Wait-DevOpsProject

            # Mock AzDoAPI_0_ProjectCache to simulate cache refresh
            Mock -CommandName AzDoAPI_0_ProjectCache
        }

        It "should create a new project even if it already exists when -Force is used" {
            New-AzDoProject -ProjectName 'NewProject' -ProjectDescription 'New Project Description' -SourceControlType 'Git' -ProcessTemplate 'Agile' -Visibility 'Private' -Force

            # Validate that New-DevOpsProject was called with correct parameters
            Assert-MockCalled -CommandName New-DevOpsProject -Exactly 1 -ParameterFilter {
                $organization -eq 'TestOrg' -and
                $projectName -eq 'NewProject' -and
                $description -eq 'New Project Description' -and
                $sourceControlType -eq 'Git' -and
                $processTemplateId -eq '12345' -and
                $visibility -eq 'Private'
            }

            # Validate that Wait-DevOpsProject was called with correct parameters
            Assert-MockCalled -CommandName Wait-DevOpsProject -Exactly 1 -ParameterFilter {
                $ProjectURL -eq 'https://dev.azure.com/TestOrg/_apis/projects/ExistingProject' -and
                $OrganizationName -eq 'TestOrg'
            }

            # Validate that AzDoAPI_0_ProjectCache was called with correct parameters
            Assert-MockCalled -CommandName AzDoAPI_0_ProjectCache -Exactly 1 -ParameterFilter {
                $OrganizationName -eq 'TestOrg'
            }
        }
    }
}
