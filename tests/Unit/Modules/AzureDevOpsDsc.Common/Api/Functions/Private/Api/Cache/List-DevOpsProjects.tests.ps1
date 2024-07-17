powershell
Describe "List-DevOpsProjects Tests" {
    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { "6.0-preview.1" }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod

    Context "When OrganizationName is specified" {
        It "should call Invoke-AzDevOpsApiRestMethod with correct parameters and return project list" {
            $mockResult = [PSCustomObject]@{ value = @("Project1", "Project2") }
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { $mockResult }

            $result = List-DevOpsProjects -OrganizationName "MyOrg"

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It
            $result | Should -Be @("Project1", "Project2")
        }

        It "should call Get-AzDevOpsApiVersion if ApiVersion is not specified" {
            List-DevOpsProjects -OrganizationName "MyOrg"
            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Exactly -Times 1 -Scope It
        }

        It "should not call Get-AzDevOpsApiVersion if ApiVersion is specified" {
            List-DevOpsProjects -OrganizationName "MyOrg" -ApiVersion "5.1"
            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Exactly -Times 0 -Scope It
        }

        It "should return null if Invoke-AzDevOpsApiRestMethod returns no value" {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { [PSCustomObject]@{ value = $null } }

            $result = List-DevOpsProjects -OrganizationName "MyOrg"
            $result | Should -Be $null
        }
    }

    Context "When OrganizationName is not specified" {
        It "should throw an error" {
            { List-DevOpsProjects -ApiVersion "5.1" } | Should -Throw
        }
    }
}

