
Describe "List-DevOpsProjects" {

    Mock -CommandName Get-AzDevOpsApiVersion {
        return "6.0"
    }

    Mock -CommandName Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{ name = "Project1"; id = "123" },
                @{ name = "Project2"; id = "456" }
            )
        }
    }

    It "Returns project list when called with valid organization name" {
        $result = List-DevOpsProjects -OrganizationName "TestOrg"
        $result | Should -Not -BeNullOrEmpty
        $result.Count | Should -Be 2
        $result[0].name | Should -Be "Project1"
        $result[1].name | Should -Be "Project2"
    }

    It "Returns null when no projects found" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            return @{ value = @() }
        }

        $result = List-DevOpsProjects -OrganizationName "TestOrg"
        $result | Should -BeNull
    }

    It "Uses default API version when not specified" {
        $result = List-DevOpsProjects -OrganizationName "TestOrg"
        $params = Get-MockDynamicParameters -CommandName Invoke-AzDevOpsApiRestMethod
        $params.Uri | Should -Match "_apis/projects"
    }

    It "Allows overriding the API version" {
        $result = List-DevOpsProjects -OrganizationName "TestOrg" -ApiVersion "5.1"
        $params = Get-MockDynamicParameters -CommandName Invoke-AzDevOpsApiRestMethod
        $params.Uri | Should -Match "_apis/projects"
    }

}

