Describe 'Get-AzDevOpsApiHttpRequestHeader' {
    Mock -CommandName Test-AzDevOpsPat -MockWith { return $true }

    Context 'when called with valid PAT' {
        It 'should return a hashtable with Authorization header' {
            $Pat = 'ValidPAT'
            $ExpectedHeader = @{
                Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
            }

            $Result = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

            $Result | Should -BeOfType 'Hashtable'
            $Result['Authorization'] | Should -BeExactly $ExpectedHeader['Authorization']
        }
    }

    Context 'when called with invalid PAT' {
        Mock -CommandName Test-AzDevOpsPat -MockWith { return $false }

        It 'should throw a validation exception' {
            { Get-AzDevOpsApiHttpRequestHeader -Pat 'InvalidPAT' } | Should -Throw -ErrorId ParameterArgumentValidationError
        }
    }
}

