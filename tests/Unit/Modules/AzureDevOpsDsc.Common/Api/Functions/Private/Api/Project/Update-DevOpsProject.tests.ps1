Describe "Update-DevOpsProject" {
    BeforeAll {
        function Invoke-AzDevOpsApiRestMethod {
            param($Uri, $Body, $Method)
            return @{
                name = "NewProjectName"
                description = "Updated project description"
                visibility = "public"
            }
        }
    }

    It "Should throw an error when Organization parameter is missing" {
        { Update-DevOpsProject -ProjectId "MyProject" -NewName "NewProjectName" -Description "Updated project description" -Visibility "public" -PersonalAccessToken "PAT" } | Should -Throw
    }

    It "Should update the project with the specified parameters" {
        $result = Update-DevOpsProject -Organization "contoso" -ProjectId "MyProject" -NewName "NewProjectName" -Description "Updated project description" -Visibility "public" -PersonalAccessToken "PAT"

        $result.name | Should -Be "NewProjectName"
        $result.description | Should -Be "Updated project description"
        $result.visibility | Should -Be "public"
    }

    It "Should set the visibility to private when specified" {
        $result = Update-DevOpsProject -Organization "contoso" -ProjectId "MyProject" -NewName "NewProjectName" -Description "Updated project description" -Visibility "private" -PersonalAccessToken "PAT"

        $result.visibility | Should -Be "private"
    }
}

