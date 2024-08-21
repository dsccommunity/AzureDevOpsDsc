$currentFile = $MyInvocation.MyCommand.Path

Describe 'New-DevOpsProject' {
    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-DevOpsProject.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            @{
                id = "1234"
                name = "MyProject"
                description = "This is a new project"
                visibility = "private"
            }
        }
    }

    Context 'Creates a new Azure DevOps project with valid parameters' {

        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters and return the project details' {
            $organization = "myorg"
            $projectName = "MyProject"
            $projectDescription = "This is a new project"
            $sourceControlType = "Git"
            $processTemplateId = "6b724908-ef14-45cf-84f8-768b5384da45"
            $visibility = "private"
            $apiVersion = "6.0"

            $result = New-DevOpsProject -Organization $organization -ProjectName $projectName -Description $projectDescription -SourceControlType $sourceControlType -ProcessTemplateId $processTemplateId -Visibility $visibility -ApiVersion $apiVersion

            $result | Should -Not -BeNullOrEmpty
            $result.name | Should -Be $projectName
            $result.description | Should -Be $projectDescription

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -ParameterFilter {
                $params = $_
                $APIUri -eq "https://dev.azure.com/$organization/_apis/projects?api-version=$apiVersion" -and
                $Method -eq "POST" -and
                $Body -ne $null
            }

        }
    }

    Context 'Handles errors gracefully' {
        BeforeEach {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API call failed" } -Verifiable
            Mock -CommandName Write-Error
        }

        It 'Should return an error message if API call fails' {
            {
                New-DevOpsProject -Organization "myorg" -ProjectName "MyProject" -Description "This is a new project" -SourceControlType "Git" -ProcessTemplateId "6b724908-ef14-45cf-84f8-768b5384da45" -Visibility "private" -ApiVersion "6.0"
            } | Should -Not -Throw

        }
    }

    Context 'Validates parameters correctly' {

        It 'Should validate ProjectName using Test-AzDevOpsProjectName' {

            # Mock the Test-AzDevOpsProjectName function to return $true
            Mock -CommandName Test-AzDevOpsProjectName -MockWith { $true }

            $organization = "myorg"
            $projectName = "MyProject"
            $projectDescription = "This is a new project"
            $sourceControlType = "Git"
            $processTemplateId = "6b724908-ef14-45cf-84f8-768b5384da45"
            $visibility = "private"
            $apiVersion = "6.0"

            $result = New-DevOpsProject -Organization $organization -ProjectName $projectName -Description $projectDescription -SourceControlType $sourceControlType -ProcessTemplateId $processTemplateId -Visibility $visibility -ApiVersion $apiVersion

            Assert-MockCalled -CommandName Test-AzDevOpsProjectName -Times 1

        }
    }
}
