
Describe 'Get-AzDevOpsApiVersion' {
    Context 'When called without parameters' {
        It 'Should return all supported API versions' {
            $result = Get-AzDevOpsApiVersion
            $expected = @('6.0', '7.0-preview.1', '7.1-preview.1')
            $result | Should -BeExactly $expected
        }
    }

    Context 'When called with -Default switch' {
        It 'Should return only the default API version' {
            $result = Get-AzDevOpsApiVersion -Default
            $expected = @('7.0-preview.1')
            $result | Should -BeExactly $expected
        }
    }
}

