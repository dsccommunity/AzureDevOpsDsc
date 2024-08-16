
Describe 'Update-DevOpsProject' {

    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            name = $params.Body.name
            description = $params.Body.description
            visibility = $params.Body.visibility
        }
    }

    $commonParams = @{
        Organization        = 'contoso'
        ProjectId           = 'MyProject'
        ApiVersion          = '6.0'
    }

    It 'Should update project with new name and description' {
        $params = $commonParams + @{
            NewName             = 'NewProjectName'
            Description         = 'Updated project description'
        }

        $result = Update-DevOpsProject @params

        $result.name | Should -Be 'NewProjectName'
        $result.description | Should -Be 'Updated project description'
    }

    It 'Should update project visibility to public' {
        $params = $commonParams + @{
            Visibility          = 'public'
        }

        $result = Update-DevOpsProject @params

        $result.visibility | Should -Be 'public'
    }

    It 'Should not include description if not provided' {
        $params = $commonParams + @{
            Visibility          = 'private'
        }

        $result = Update-DevOpsProject @params

        $result.PSObject.Properties.Match('description') | Should -Be $null
    }

    It 'Should handle failure gracefully' {
        Mock Invoke-AzDevOpsApiRestMethod { throw 'API error' }

        { Update-DevOpsProject @commonParams } | Should -Throw 'API error'
    }
}

