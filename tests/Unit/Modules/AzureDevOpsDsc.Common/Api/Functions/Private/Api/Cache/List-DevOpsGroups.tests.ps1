
# Unit Test Code for List-DevOpsGroups function using Pester v5

Describe 'List-DevOpsGroups' {
    Mock Get-AzDevOpsApiVersion { return '6.0-preview' }
    Mock Invoke-AzDevOpsApiRestMethod { return @{ value = @( @{ id = '1'; displayName = 'Group1' }, @{ id = '2'; displayName = 'Group2' } ) } }

    It 'should call Get-AzDevOpsApiVersion if no ApiVersion is specified' {
        List-DevOpsGroups -Organization 'myOrg'
        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
    }

    It 'should not call Get-AzDevOpsApiVersion if ApiVersion is specified' {
        List-DevOpsGroups -Organization 'myOrg' -ApiVersion '5.1'
        Assert-MockNotCalled Get-AzDevOpsApiVersion
    }

    It 'should use the supplied ApiVersion' {
        List-DevOpsGroups -Organization 'myOrg' -ApiVersion '5.1'
        # Ensure the ApiVersion parameter wasn't used but mocked instead
        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter { $params.Uri -eq 'https://vssps.dev.azure.com/myOrg/_apis/graph/groups' -and $params.ApiVersion -eq '5.1'}
    }

    It 'should return group data' {
        $result = List-DevOpsGroups -Organization 'myOrg'
        $result | Should -BeOfType 'System.Object[]'
        $result.Count | Should -Be 2
        $result[0].displayName | Should -Be 'Group1'
    }

    It 'should return null if no groups are found' {
        Mock Invoke-AzDevOpsApiRestMethod { return @{ value = $null } }
        $result = List-DevOpsGroups -Organization 'myOrg'
        $result | Should -Be $null
    }
}


