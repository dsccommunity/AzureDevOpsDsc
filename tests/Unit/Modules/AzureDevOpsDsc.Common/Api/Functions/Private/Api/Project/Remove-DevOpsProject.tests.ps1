
Describe "Remove-DevOpsProject" {
    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "5.1-preview.1" }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod

    Context "When removing a project" {
        It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            $org = "MyOrganization"
            $projectId = "MyProject"
            $apiVersion = "5.1-preview.1"

            Remove-DevOpsProject -Organization $org -ProjectId $projectId

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $Uri -eq "https://dev.azure.com/$org/_apis/projects/$projectId?api-version=$apiVersion" -and
                $Method -eq "DELETE"
            }
        }
    }

    Context "When an exception occurs" {
        It "Should write an error message" {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API call failed" }

            { Remove-DevOpsProject -Organization "MyOrganization" -ProjectId "MyProject" } | Should -Throw
        }
    }
}

