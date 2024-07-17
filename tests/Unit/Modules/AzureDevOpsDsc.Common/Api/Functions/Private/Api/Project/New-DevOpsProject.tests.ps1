powershell
Describe 'New-DevOpsProject' {
    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            id = "sample-project-id"
            name = $using:ProjectName
            description = $using:Description
            visibility = $using:Visibility
        }
    }

    Context 'When provided valid parameters' {
        $Organization = "myorg"
        $ProjectName = "MyProject"
        $Description = "This is a new project"
        $Visibility = "private"
        $PersonalAccessToken = "mytoken"

        It 'Creates a new DevOps project' {
            $response = New-DevOpsProject -Organization $Organization -ProjectName $ProjectName -Description $Description -Visibility $Visibility -PersonalAccessToken $PersonalAccessToken
            
            $response | Should -Not -BeNullOrEmpty
            $response.id | Should -Be "sample-project-id"
            $response.name | Should -Be $ProjectName
            $response.description | Should -Be $Description
            $response.visibility | Should -Be $Visibility

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope it
        }
    }

    Context 'When an error occurs during project creation' {
        Mock Invoke-AzDevOpsApiRestMethod { throw "API Error" }

        $Organization = "myorg"
        $ProjectName = "MyProject"
        $Description = "This is a new project"
        $Visibility = "private"
        $PersonalAccessToken = "mytoken"

        It 'Throws an error' {
            {
                New-DevOpsProject -Organization $Organization -ProjectName $ProjectName -Description $Description -Visibility $Visibility -PersonalAccessToken $PersonalAccessToken
            } | Should -Throw -ErrorId 'Write-Error'
        }
    }
}

