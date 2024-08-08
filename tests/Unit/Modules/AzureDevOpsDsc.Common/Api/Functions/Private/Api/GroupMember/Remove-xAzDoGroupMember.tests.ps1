Describe "Remove-DevOpsGroupMember Tests" {
    Mock -ModuleName ModuleName -FunctionName Get-AzDevOpsApiVersion {
        return "5.1-preview.1"
    }

    Mock -ModuleName ModuleName -FunctionName Invoke-AzDevOpsApiRestMethod {
        return $null
    }

    $mockGroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
    $mockMemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
    $mockApiUri = "https://dev.azure.com/organization"

    Context "When called with valid parameters" {
        It "should call Get-AzDevOpsApiVersion if ApiVersion is not provided" {
            Remove-DevOpsGroupMember -GroupIdentity $mockGroupIdentity -MemberIdentity $mockMemberIdentity -ApiUri $mockApiUri
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        }

        It "should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            Remove-DevOpsGroupMember -GroupIdentity $mockGroupIdentity -MemberIdentity $mockMemberIdentity -ApiUri $mockApiUri -ApiVersion "5.1-preview.1"
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $Uri -eq "https://dev.azure.com/organization/_apis/graph/memberships/member-descriptor/group-descriptor?api-version=5.1-preview.1" -and
                $Method -eq "DELETE"
            }
        }

        It "should not catch an error if the API call is successful" {
            {Remove-DevOpsGroupMember -GroupIdentity $mockGroupIdentity -MemberIdentity $mockMemberIdentity -ApiUri $mockApiUri -ApiVersion "5.1-preview.1"} | Should -Not -Throw
        }
    }

    Context "When an exception occurs in Invoke-AzDevOpsApiRestMethod" {
        Mock -ModuleName ModuleName -FunctionName Invoke-AzDevOpsApiRestMethod {
            throw "API call failed"
        }

        It "should catch and log the error" {
            {Remove-DevOpsGroupMember -GroupIdentity $mockGroupIdentity -MemberIdentity $mockMemberIdentity -ApiUri $mockApiUri -ApiVersion "5.1-preview.1"} | Should -Throw
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1
        }
    }
}

