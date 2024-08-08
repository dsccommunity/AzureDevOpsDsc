powershell
Describe "New-DevOpsProject" {
    
    Mock -CommandName 'Test-AzDevOpsProjectName' -MockWith {
        return $true
    }

    Mock -CommandName 'Get-AzDevOpsApiVersion' -MockWith {
        return "6.0-preview.4"
    }

    Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
        return @{ id = "1"; name = "MyProject"; description = "This is a new project"; visibility = "private" }
    }

    $params = @{
        Organization       = "myorg"
        ProjectName        = "MyProject"
        ProjectDescription = "This is a new project"
        SourceControlType  = "Git"
        ProcessTemplateId  = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
        Visibility         = "private"
    }

    It "Creates a new Azure DevOps project" {
        $result = New-DevOpsProject @params

        $result.id | Should -Not -BeNullOrEmpty
        $result.name | Should -Be $params.ProjectName
        $result.description | Should -Be $params.ProjectDescription
        $result.visibility | Should -Be $params.Visibility
    }

    It "Calls Test-AzDevOpsProjectName with the correct parameters" {
        $result = New-DevOpsProject @params

        Assert-MockCalled -CommandName 'Test-AzDevOpsProjectName' -Exactly -Times 1 -Scope It -ParameterFilter {
            $ProjectName -eq $params.ProjectName -and $_.IsValid
        }
    }

    It "Calls Get-AzDevOpsApiVersion" {
        $result = New-DevOpsProject @params
    
        Assert-MockCalled -CommandName 'Get-AzDevOpsApiVersion' -Exactly -Times 1 -Scope It
    }

    It "Calls Invoke-AzDevOpsApiRestMethod with the correct parameters" {
        $result = New-DevOpsProject @params

        Assert-MockCalled -CommandName 'Invoke-AzDevOpsApiRestMethod' -Exactly -Times 1 -Scope It -ParameterFilter {
            $Uri -eq "https://dev.azure.com/myorg/_apis/projects?api-version=6.0-preview.4" -and
            $Method -eq "POST" -and
            $Body -eq (@{
                name         = "MyProject"
                description  = "This is a new project"
                visibility   = "private"
                capabilities = @{
                    versioncontrol = @{
                        sourceControlType = "Git"
                    }
                    processTemplate = @{
                        templateTypeId = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
                    }
                }
            } | ConvertTo-Json)
        }
    }
    
    It "Throws an error if the response is null" {
        Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
            return $null
        }
        { New-DevOpsProject @params } | Should -Throw -ErrorId "New-DevOpsProject"
    }
}

