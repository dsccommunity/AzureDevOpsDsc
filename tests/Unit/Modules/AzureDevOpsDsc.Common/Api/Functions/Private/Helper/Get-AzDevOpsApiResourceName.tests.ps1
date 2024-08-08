Describe 'Get-AzDevOpsApiResourceName' {
    It 'Should return an array of strings' {
        $result = Get-AzDevOpsApiResourceName
        $result | Should -BeOfType [System.String[]]
    }

    It 'Should return expected resource names' {
        $expected = @('Operation', 'Project')
        $result = Get-AzDevOpsApiResourceName
        $result | Should -Be $expected
    }

    It 'Should not return an empty array' {
        $result = Get-AzDevOpsApiResourceName
        $result.Length | Should -BeGreaterThan 0
    }
}

