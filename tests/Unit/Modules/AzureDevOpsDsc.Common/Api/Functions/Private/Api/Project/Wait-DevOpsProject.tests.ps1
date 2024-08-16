
Describe 'Wait-DevOpsProject' {
    Mock Invoke-AzDevOpsApiRestMethod

    Context 'When Project is created successfully' {
        It 'Stops retrying after project is wellFormed' {
            Mock Invoke-AzDevOpsApiRestMethod { return @{ status = "wellFormed" } }

            { Wait-DevOpsProject -OrganizationName "TestOrg" -ProjectURL "https://dev.azure.com/TestOrg/TestProject" } | Should -Not -Throw
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Times 1
        }
    }

    Context 'When Project creation fails' {
        It 'Handles failed status correctly' {
            Mock Invoke-AzDevOpsApiRestMethod { return @{ status = "failed" } }

            { Wait-DevOpsProject -OrganizationName "TestOrg" -ProjectURL "https://dev.azure.com/TestOrg/TestProject" } | Should -Throw
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Times 1
        }
    }

    Context 'When Project creation times out' {
        It 'Retries 10 times before timing out' {
            Mock Invoke-AzDevOpsApiRestMethod { return @{ status = "creating" } }

            { Wait-DevOpsProject -OrganizationName "TestOrg" -ProjectURL "https://dev.azure.com/TestOrg/TestProject" } | Should -Throw
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Times 10
        }
    }

    Context 'When Project status is not set' {
        It 'Throws an error when status is notSet' {
            Mock Invoke-AzDevOpsApiRestMethod { return @{ status = "notSet" } }

            { Wait-DevOpsProject -OrganizationName "TestOrg" -ProjectURL "https://dev.azure.com/TestOrg/TestProject" } | Should -Throw
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Times 1
        }
    }

    Context 'When Project status default case' {
        It 'Retries if project is still being created (default case)' {
            Mock Invoke-AzDevOpsApiRestMethod { return @{ status = "unknown" } }

            { Wait-DevOpsProject -OrganizationName "TestOrg" -ProjectURL "https://dev.azure.com/TestOrg/TestProject" } | Should -Throw
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Times 10
        }
    }
}

