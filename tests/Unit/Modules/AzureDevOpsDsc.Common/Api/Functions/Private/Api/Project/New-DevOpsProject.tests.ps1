
Describe 'New-DevOpsProject' {
    Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
        @{
            id = "1234"
            name = "MyProject"
            description = "This is a new project"
            visibility = "private"
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

            Assert-MockCalled -CommandName 'Invoke-AzDevOpsApiRestMethod' -Times 1 -Exactly -Scope It -ParameterFilter {
                $params = $_
                $params.Uri -eq "https://dev.azure.com/$organization/_apis/projects?api-version=$apiVersion" -and
                $params.Method -eq "POST" -and
                $params.Body.name -eq $projectName -and
                $params.Body.description -eq $projectDescription -and
                $params.Body.visibility -eq $visibility
            }
        }
    }

    Context 'Handles errors gracefully' {
        Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
            throw "API call failed"
        }

        It 'Should return an error message if API call fails' {
            {
                New-DevOpsProject -Organization "myorg" -ProjectName "MyProject" -Description "This is a new project" -SourceControlType "Git" -ProcessTemplateId "6b724908-ef14-45cf-84f8-768b5384da45" -Visibility "private" -ApiVersion "6.0"
            } | Should -Throw -ErrorMessage "\[New-DevOpsProject\] Failed to create the Azure DevOps project: API call failed"
        }
    }
}

