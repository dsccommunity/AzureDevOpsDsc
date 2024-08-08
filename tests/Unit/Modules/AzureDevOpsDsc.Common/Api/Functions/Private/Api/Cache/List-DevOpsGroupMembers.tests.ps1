powershell
Describe "List-DevOpsGroupMembers" {
    Mock -CommandName Get-AzDevOpsApiVersion {
        return "6.0-preview.1"
    }

    Mock -CommandName Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{principalName = "user1@domain.com"},
                @{principalName = "user2@domain.com"}
            )
        }
    }

    It "Should return the correct group members when correct params are passed" {
        $Organization = "testOrg"
        $GroupDescriptor = "testGroup"

        $result = List-DevOpsGroupMembers -Organization $Organization -GroupDescriptor $GroupDescriptor

        $result | Should -Not -BeNullOrEmpty
        $result | Should -HaveCount 2
        $result[0].principalName | Should -Be "user1@domain.com"
        $result[1].principalName | Should -Be "user2@domain.com"
    }

    It "Should use the default API version if none is specified" {
        $Organization = "testOrg"
        $GroupDescriptor = "testGroup"

        $result = List-DevOpsGroupMembers -Organization $Organization -GroupDescriptor $GroupDescriptor

        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
            $Uri -eq "https://vssps.dev.azure.com/testOrg/_apis/graph/Memberships/testGroup?direction=down"
        } -Exactly 1
    }

    It "Should return null when the membership value is null" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            return @{ value = $null }
        }

        $Organization = "testOrg"
        $GroupDescriptor = "testGroup"

        $result = List-DevOpsGroupMembers -Organization $Organization -GroupDescriptor $GroupDescriptor

        $result | Should -Be $null
    }
}

