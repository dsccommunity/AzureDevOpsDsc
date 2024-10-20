$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-BitwiseOrResult' -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-BitwiseOrResult.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    It 'should return 0 for an empty array' {
        $result = Get-BitwiseOrResult -integers @()
        $result | Should -Be 0
    }

    It 'should return a value for an array with a single item' {
        $result = Get-BitwiseOrResult -integers 5
        $result | Should -Be 5
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
        { Get-BitwiseOrResult -integers @($invalidInteger) } | Should -Throw
    }

    It 'should return correct result for mixture of valid integers' {
        $result = Get-BitwiseOrResult -integers @(-1, 1)
        $result | Should -Be -1
    }

}
