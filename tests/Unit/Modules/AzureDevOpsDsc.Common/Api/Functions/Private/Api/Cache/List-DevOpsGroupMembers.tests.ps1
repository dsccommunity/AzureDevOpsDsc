
Describe 'List-DevOpsGroupMembers' {
    Mock Get-AzDevOpsApiVersion { return '6.0-preview.1' }
    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{principalName = 'user1@domain.com'}
                @{principalName = 'user2@domain.com'}
            )
        }
    }

    Context 'When called with mandatory parameters' {
        It 'Should return group members' {
            $result = List-DevOpsGroupMembers -Organization 'MyOrg' -GroupDescriptor 'MyGroup'
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Contain @{principalName = 'user1@domain.com'}
            $result | Should -Contain @{principalName = 'user2@domain.com'}
        }
    }

    Context 'When no members are found' {
        Mock Invoke-AzDevOpsApiRestMethod {
            return @{
                value = $null
            }
        }

        It 'Should return null' {
            $result = List-DevOpsGroupMembers -Organization 'MyOrg' -GroupDescriptor 'MyGroup'
            $result | Should -Be $null
        }
    }

    Context 'When optional ApiVersion parameter is provided' {
        Mock Get-AzDevOpsApiVersion { return '5.0' }

        It 'Should ignore Get-AzDevOpsApiVersion and use provided ApiVersion' {
            # Inject expected ApiVersion
            List-DevOpsGroupMembers -Organization 'MyOrg' -GroupDescriptor 'MyGroup' -ApiVersion '6.0-preview.1'

            $invocationInfo = (Get-MockDynamicParams | Where-Object { $_.CommandName -eq 'Invoke-AzDevOpsApiRestMethod' }).Args[0]
            $invocationInfo.Uri | Should -Contain '6.0-preview.1'
        }
    }
}

