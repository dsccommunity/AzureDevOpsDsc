Describe "ConvertTo-Base64String" {
    BeforeAll {
        function ConvertTo-Base64String {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory, ValueFromPipeline)]
                [ValidateNotNullOrEmpty()]
                [String]
                $InputObject
            )

            process {
                [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($InputObject))
            }
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
        $expected = "IUAjJCVeJiooKV8rfg=="

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

