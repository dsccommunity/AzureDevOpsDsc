powershell
Describe "List-DevOpsGroups" {
    Mock -CommandName Get-AzDevOpsApiVersion {
        return "5.1-preview.1"
    }

    Mock -CommandName Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{
                    id = "group1"
                    displayName = "Group 1"
                },
                @{
                    id = "group2"
                    displayName = "Group 2"
                }
            )
        }
    }

    Context "When called with mandatory parameter" {
        It "Should return groups" {
            $Organization = "sampleOrg"
            $result = List-DevOpsGroups -Organization $Organization
            $result | Should -Not -BeNullOrEmpty
            $result.count | Should -Be 2
            $result[0].displayName | Should -Be "Group 1"
            $result[1].displayName | Should -Be "Group 2"
        }
    }

    Context "When API call returns null value" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            return @{ value = $null }
        }

        It "Should return null" {
            $Organization = "sampleOrg"
            $result = List-DevOpsGroups -Organization $Organization
            $result | Should -BeNull
        }
    }
}

