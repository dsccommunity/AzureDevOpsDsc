powershell
# Unit Tests for Get-BitwiseOrResult function using Pester v5

# Import Pester module if not already imported
Import-Module Pester -ErrorAction SilentlyContinue

Describe 'Get-BitwiseOrResult' {
    It 'should return 0 for an empty array' {
        $result = Get-BitwiseOrResult -integers @()
        $result | Should -Be 0
    }

    It 'should return the same number for a single-item array' {
        $result = Get-BitwiseOrResult -integers @(5)
        $result | Should -Be 5
    }

    It 'should return correct bitwise OR result for an array of positive integers' {
        $result = Get-BitwiseOrResult -integers @(1, 2, 4, 8)
        $result | Should -Be 15
    }

    It 'should handle large numbers correctly' {
        $result = Get-BitwiseOrResult -integers @(2147483647, 1)
        $result | Should -Be 2147483647
    }

    It 'should return 0 for an array with all zeros' {
        $result = Get-BitwiseOrResult -integers @(0, 0, 0)
        $result | Should -Be 0
    }

    It 'should write error and return null for an invalid integer' {
        $invalidInteger = "abc"
        { Get-BitwiseOrResult -integers @($invalidInteger) } | Should -Throw -ErrorId "Invalid integer value: $invalidInteger"
    }

    It 'should return correct result for mixture of valid integers' {
        $result = Get-BitwiseOrResult -integers @(-1, 1)
        $result | Should -Be -1
    }
}

# Run the tests
Invoke-Pester

