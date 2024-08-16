
Describe 'Remove-DevOpsGroupMember' {
    Mock Get-AzDevOpsApiVersion { return '6.0-preview' }
    Mock Invoke-AzDevOpsApiRestMethod { return $null }

    Context 'When all parameters are valid' {
        It 'Removes a member from the group' {
            $group = [PSCustomObject]@{ descriptor = 'group-descriptor' }
            $member = [PSCustomObject]@{ descriptor = 'member-descriptor' }
            $apiUri = 'https://dev.azure.com/myorg'

            Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri

            Assert-MockCalled Get-AzDevOpsApiVersion -Times 1
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $_.Uri -eq 'https://dev.azure.com/myorg/_apis/graph/memberships/member-descriptor/group-descriptor?api-version=6.0-preview' -and
                $_.Method -eq 'DELETE'
            } -Times 1
        }
    }

    Context 'When API call fails' {
        It 'Handles the error gracefully' {
            Mock Invoke-AzDevOpsApiRestMethod { throw 'API call failed' }

            $group = [PSCustomObject]@{ descriptor = 'group-descriptor' }
            $member = [PSCustomObject]@{ descriptor = 'member-descriptor' }
            $apiUri = 'https://dev.azure.com/myorg'

            { Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri } | Should -Throw
        }
    }

    Context 'When ApiVersion parameter is provided' {
        It 'Uses the specified ApiVersion' {
            $group = [PSCustomObject]@{ descriptor = 'group-descriptor' }
            $member = [PSCustomObject]@{ descriptor = 'member-descriptor' }
            $apiUri = 'https://dev.azure.com/myorg'
            $apiVersion = '6.0'

            Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri -ApiVersion $apiVersion

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $_.Uri -eq 'https://dev.azure.com/myorg/_apis/graph/memberships/member-descriptor/group-descriptor?api-version=6.0' -and
                $_.Method -eq 'DELETE'
            } -Times 1
        }
    }
}

