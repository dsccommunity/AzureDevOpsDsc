powershell
Describe 'Get-DevOpsSecurityDescriptor' {
    Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' {
        return @{
            value = @{
                securityDescriptor = 'sample-descriptor'
            }
        }
    }

    Context 'When called with valid parameters' {
        It 'Should return the security descriptor' {
            $ProjectId = 'sample-project-id'
            $Organization = 'sample-org'
            $ApiVersion = '6.0-preview.1'

            $result = Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion

            $result.securityDescriptor | Should -Be 'sample-descriptor'
        }
    }

    Context 'When called with missing mandatory parameters' {
        It 'Should throw an error if ProjectId is missing' {
            { Get-DevOpsSecurityDescriptor -Organization 'sample-org' -ApiVersion '6.0-preview.1' } | Should -Throw
        }

        It 'Should throw an error if Organization is missing' {
            { Get-DevOpsSecurityDescriptor -ProjectId 'sample-project-id' -ApiVersion '6.0-preview.1' } | Should -Throw
        }
    }
    
    Context 'When Invoke-AzDevOpsApiRestMethod throws an exception' {
        Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
            throw "API failure"
        }

        It 'Should catch the exception and write an error' {
            $ProjectId = 'sample-project-id'
            $Organization = 'sample-org'
            
            { Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization } | Should -Throw
        }
    }
}

