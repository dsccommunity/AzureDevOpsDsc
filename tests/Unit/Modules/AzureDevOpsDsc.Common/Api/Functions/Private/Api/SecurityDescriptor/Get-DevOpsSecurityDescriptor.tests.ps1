
Describe 'Get-DevOpsSecurityDescriptor Tests' {
    Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
        return @{ value = 'MockedResponse' }
    }

    BeforeEach {
        $ProjectId = 'TestProjectId'
        $Organization = 'TestOrganization'
        $ApiVersion = '6.0'
    }

    It 'should retrieve the security descriptor for a project' {
        $response = Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion
        $response | Should -Be 'MockedResponse'
    }

    It 'should call Invoke-AzDevOpsApiRestMethod once' {
        Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion
        Assert-MockCalled 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -Scope IT
    }

    It 'should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
        Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion
        Assert-MockCalled 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -Scope IT -ParameterFilter {
            $params.Uri -eq "https://vssps.dev.azure.com/TestOrganization/_apis/graph/descriptors/TestProjectId?api-version=6.0" -and
            $params.Method -eq 'Get'
        }
    }

    It 'should handle errors gracefully' {
        Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith { throw "API Error" }

        { Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion } | Should -Throw -ErrorId "Write-Error"
    }
}

