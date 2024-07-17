powershell
Describe "Remove-DevOpsGroupMember" {
    Mock Get-AzDevOpsApiVersion { return "6.0-preview.1" }
    Mock Invoke-AzDevOpsApiRestMethod {
        return @{message = "Member removed successfully."}
    }
    
    Context "When running Remove-DevOpsGroupMember" {
        $group = [PSCustomObject]@{ descriptor = "group-descriptor" }
        $member = [PSCustomObject]@{ descriptor = "member-descriptor" }
        $apiUri = "https://dev.azure.com/org"

        It "Should call Get-AzDevOpsApiVersion if ApiVersion is not provided" {
            Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly -Times 1
        }

        It "Should not call Get-AzDevOpsApiVersion if ApiVersion is provided" {
            Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri -ApiVersion "5.1"

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly -Times 0
        }

        It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri

            $expectedParams = @{
                Uri    = "https://dev.azure.com/org/_apis/graph/memberships/member-descriptor/group-descriptor?api-version=6.0-preview.1"
                Method = 'DELETE'
            }

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -ParameterFilter { 
                $Uri -eq $expectedParams.Uri -and $Method -eq $expectedParams.Method 
            }
        }

        It "Should return the expected result" {
            $result = Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri

            $result.message | Should -Be "Member removed successfully."
        }

        It "Should catch exceptions from Invoke-AzDevOpsApiRestMethod" {
            Mock Invoke-AzDevOpsApiRestMethod { throw "API Error" } -Verifiable

            { Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri } | Should -Throw "API Error"
        }
    }
}

