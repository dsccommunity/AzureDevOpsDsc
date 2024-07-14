powershell
Describe 'Get-AzDevOpsApiResourceName' {
    It 'Returns an array of strings' {
        $result = Get-AzDevOpsApiResourceName
        $result | Should -BeOfType [System.String[]]
    }

    It 'Returns the expected resource names' {
        $expected = @('Operation', 'Project')
        $result = Get-AzDevOpsApiResourceName
        $result | Should -Be $expected
    }

    It 'Does not return empty or null' {
        $result = Get-AzDevOpsApiResourceName
        $result | Should -Not -BeNullOrEmpty
    }
}

