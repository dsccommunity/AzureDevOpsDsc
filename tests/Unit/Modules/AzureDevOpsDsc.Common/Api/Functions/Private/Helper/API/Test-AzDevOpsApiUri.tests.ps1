Describe 'Test-AzDevOpsApiUri' {
    Mock function assert {
        param (
            [string]$ApiUri,
            [switch]$IsValid
        )

        return $true
    }

    It 'Returns $true if ApiUri is null or empty' {
        $result = Test-AzDevOpsApiUri -ApiUri '' -IsValid
        $result | Should -Be $true
    }

    It 'Returns $true for a valid HTTP URI when -IsValid is used' {
        $result = Test-AzDevOpsApiUri -ApiUri 'http://example.com/_apis/' -IsValid
        $result | Should -Be $true
    }

    It 'Returns $true for a valid HTTPS URI when -IsValid is used' {
        $result = Test-AzDevOpsApiUri -ApiUri 'https://example.com/_apis/' -IsValid
        $result | Should -Be $true
    }

    It 'Returns $false for an invalid HTTP URI when -IsValid is used' {
        $result = Test-AzDevOpsApiUri -ApiUri 'http://example.com/invalid' -IsValid
        $result | Should -Be $false
    }

    It 'Returns $false for an invalid HTTPS URI when -IsValid is used' {
        $result = Test-AzDevOpsApiUri -ApiUri 'https://example.com/invalid' -IsValid
        $result | Should -Be $false
    }

    It 'Throws an exception if -IsValid is not used' {
        { Test-AzDevOpsApiUri -ApiUri 'http://example.com/_apis/' } | Should -Throw
    }
}

