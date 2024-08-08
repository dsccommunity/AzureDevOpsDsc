Describe "List-DevOpsGroups" {
    Param (
        [string]$Organization = "testOrg",
        [string]$ApiVersion = "6.0-preview.1"
    )

    Mock -CommandName Get-AzDevOpsApiVersion { return "6.0-preview.1" }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{
                    displayName = "Project Administrators"
                    originId = "abc123"
                },
                @{
                    displayName = "Contributors"
                    originId = "def456"
                }
            )
        }
    }

    Context "Valid Parameters" {
        It "Should return groups" {
            $result = List-DevOpsGroups -Organization $Organization

            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType Array
            $result.Count | Should -Be 2

            $result[0].displayName | Should -Be "Project Administrators"
            $result[0].originId | Should -Be "abc123"
            $result[1].displayName | Should -Be "Contributors"
            $result[1].originId | Should -Be "def456"
        }
    }

    Context "No Groups Returned" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod { return @{ value = $null } }

        It "Should return null if no groups" {
            $result = List-DevOpsGroups -Organization $Organization

            $result | Should -BeNull
        }
    }

    Context "Mandatory Parameter -Organization" {
        It "Should throw an error if missing -Organization" {
            { List-DevOpsGroups } | Should -Throw -ErrorId "ParameterArgumentTransformationError"
        }
    }
}

