$currentFile = $MyInvocation.MyCommand.Path

Describe "Set-AzDoProject" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-AzDoProject.tests.ps1'
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

        Mock -CommandName Test-AzDevOpsProjectName -MockWith {
            return $true
        }

        Mock -CommandName Get-CacheItem -MockWith {
            param ($Key, $Type)
            if ($Type -eq 'LiveProjects')
            {
                return @{ id = '12345' }
            }
            elseif ($Type -eq 'LiveProcesses')
            {
                return @{ id = '67890' }
            }
        }

        Mock -CommandName Update-DevOpsProject -MockWith {
            return @{ url = "http://devopsprojecturl" }
        }

        Mock -CommandName Wait-DevOpsProject
        Mock -CommandName AzDoAPI_0_ProjectCache

    }

    Context "When setting a project" {

        It "Should update the project in Azure DevOps and refresh the cache" {
            # Arrange
            $Global:DSCAZDO_OrganizationName = "TestOrg"
            $projectName = "TestProject"
            $projectDescription = "Test Description"
            $sourceControlType = "Git"
            $processTemplate = "Agile"
            $visibility = "Private"

            # Act
            Set-AzDoProject -ProjectName $projectName -ProjectDescription $projectDescription -SourceControlType $sourceControlType -ProcessTemplate $processTemplate -Visibility $visibility

            # Assert
            Assert-MockCalled -CommandName Get-CacheItem -Exactly -Times 1 -ParameterFilter {
                ($Key -eq $projectName) -and
                ($Type -eq 'LiveProjects')
            }
            Assert-MockCalled -CommandName Get-CacheItem -Exactly -Times 1 -ParameterFilter {
                ($Key -eq $processTemplate) -and
                ($Type -eq 'LiveProcesses')
            }
            Assert-MockCalled -CommandName Update-DevOpsProject -Exactly -Times 1 -ParameterFilter {
                ($organization -eq "TestOrg") -and
                ($projectId -eq '12345') -and
                ($description -eq $projectDescription) -and
                ($processTemplateId -eq '67890')
            }
            Assert-MockCalled -CommandName Wait-DevOpsProject -Exactly -Times 1 -ParameterFilter {
                ($ProjectURL -eq "http://devopsprojecturl") -and
                ($OrganizationName -eq "TestOrg")
            }
            Assert-MockCalled -CommandName AzDoAPI_0_ProjectCache -Exactly -Times 1 -ParameterFilter {
                $OrganizationName -eq "TestOrg"
            }
        }
    }
}
