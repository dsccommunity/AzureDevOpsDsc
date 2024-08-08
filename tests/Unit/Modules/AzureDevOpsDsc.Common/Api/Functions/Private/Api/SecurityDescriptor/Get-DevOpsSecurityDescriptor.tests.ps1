Describe 'Get-DevOpsSecurityDescriptor' {
    Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' {
        return @{ value = 'Mocked response' }
    }

    It 'Should return security descriptor when called with valid parameters' {
        $result = Get-DevOpsSecurityDescriptor -ProjectId 'ProjectID' -Organization 'MyOrganization'
        $result | Should -Be 'Mocked response'
    }

    It 'Should throw an error when ProjectId is missing' {
        { Get-DevOpsSecurityDescriptor -Organization 'MyOrganization' } | Should -Throw
    }

    It 'Should throw an error when Organization is missing' {
        { Get-DevOpsSecurityDescriptor -ProjectId 'ProjectID' } | Should -Throw
    }

    It 'Should use default ApiVersion when not specified' {
        Mock -CommandName 'Get-AzDevOpsApiVersion' -MockWith { '6.0' }
        Get-DevOpsSecurityDescriptor -ProjectId 'ProjectID' -Organization 'MyOrganization'
        Assert-MockCalled 'Get-AzDevOpsApiVersion' -Exactly 1 -Scope It
    }

    It 'Should use specified ApiVersion' {
        Get-DevOpsSecurityDescriptor -ProjectId 'ProjectID' -Organization 'MyOrganization' -ApiVersion '5.1'
        Assert-MockCalled 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -Scope It -ParameterFilter { $params.ApiVersion -eq '5.1' }
    }

    It 'Should handle API errors gracefully' {
        Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith { throw "API Error" }
        { Get-DevOpsSecurityDescriptor -ProjectId 'ProjectID' -Organization 'MyOrganization' } | Should -Throw
    }
}

