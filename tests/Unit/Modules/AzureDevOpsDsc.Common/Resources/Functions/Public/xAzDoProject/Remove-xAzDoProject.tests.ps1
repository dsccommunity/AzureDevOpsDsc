$currentFile = $MyInvocation.MyCommand.Path

Describe "Remove-AzDoProject" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-AzDoProject.tests.ps1'
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

        Mock -CommandName Test-AzDevOpsProjectName -MockWith { return $true }
        Mock -CommandName Get-CacheItem -MockWith { return @{ id = '12345' } }
        Mock -CommandName Remove-DevOpsProject
        Mock -CommandName Remove-CacheItem
        Mock -CommandName Export-CacheObject

    }

    Context "When the project exists in cache" {

        It "Should remove the project from Azure DevOps and update the cache" {
            # Arrange
            $Global:DSCAZDO_OrganizationName = "TestOrg"
            $projectName = "TestProject"

            # Act
            Remove-AzDoProject -ProjectName $projectName

            # Assert
            Assert-MockCalled -CommandName Get-CacheItem -Exactly -Times 1 -ParameterFilter {
                ($Key -eq $projectName) -and
                ($Type -eq 'LiveProjects')
            }

            Assert-MockCalled -CommandName Remove-DevOpsProject -Exactly -Times 1 -ParameterFilter {
                ($Organization -eq "TestOrg") -and
                ($ProjectId -eq '12345')
            }

            Assert-MockCalled -CommandName Remove-CacheItem -Exactly -Times 1 -ParameterFilter {
                ($Key -eq $projectName) -and
                ($Type -eq 'LiveProjects')
            }

            Assert-MockCalled -CommandName Export-CacheObject -Exactly -Times 1 -ParameterFilter {
                ($CacheType -eq 'LiveProjects') -and
                ($Content -eq $AzDoLiveProjects)
            }

        }
    }

    Context "When the project does not exist in cache" {

        It "Should not attempt to remove the project or update the cache" {

            Mock -CommandName Get-CacheItem

            # Arrange
            $Global:DSCAZDO_OrganizationName = "TestOrg"
            $projectName = "NonExistentProject"

            # Act
            Remove-AzDoProject -ProjectName $projectName

            # Assert
            Assert-MockCalled -CommandName Get-CacheItem -Exactly -Times 1 -ParameterFilter {
                $Key -eq $projectName
                $Type -eq 'LiveProjects'
            }
            Assert-MockCalled -CommandName Remove-DevOpsProject -Exactly -Times 0
            Assert-MockCalled -CommandName Remove-CacheItem -Exactly -Times 0
            Assert-MockCalled -CommandName Export-CacheObject -Exactly -Times 0

        }
    }
}
