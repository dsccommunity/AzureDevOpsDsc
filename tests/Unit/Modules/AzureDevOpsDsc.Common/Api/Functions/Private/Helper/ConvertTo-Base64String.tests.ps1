$currentFile = $MyInvocation.MyCommand.Path

Describe "ConvertTo-Base64String" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "ConvertTo-Base64String.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    It "should convert a string to a Base64 string" {
        $input = "Hello, World!"
        $expected = "SGVsbG8sIFdvcmxkIQ=="

        $result = ConvertTo-Base64String -InputObject $input

        $result | Should -Be $expected
    }

    It "should throw an error for null input" {
        { ConvertTo-Base64String -InputObject $null } | Should -Throw
    }

    It "should throw an error for empty input" {
        { ConvertTo-Base64String -InputObject "" } | Should -Throw
    }

    It "should handle special characters correctly" {
        $input = "!@#$%^&*()_+|"
        $expected = "IUAjJCVeJiooKV8rfA=="

        $result = ConvertTo-Base64String -InputObject $input

        $result | Should -Be $expected
    }

    It "should handle non-ASCII characters correctly" {
        $input = "こんにちは"
        $expected = "44GT44KT44Gr44Gh44Gv"

        $result = ConvertTo-Base64String -InputObject $input

        $result | Should -Be $expected
    }
}
