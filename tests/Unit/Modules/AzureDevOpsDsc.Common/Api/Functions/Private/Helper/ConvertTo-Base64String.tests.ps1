
Describe 'ConvertTo-Base64String' {
    It 'should convert byte array to Base64 string correctly' {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes("Hello, World!")
        $result = ConvertTo-Base64String -InputObject $bytes
        $result | Should -Be "SGVsbG8sIFdvcmxkIQ=="
    }

    It 'should throw an error for null InputObject' {
        { ConvertTo-Base64String -InputObject $null } | Should -Throw
    }

    It 'should throw an error for empty InputObject' {
        { ConvertTo-Base64String -InputObject "" } | Should -Throw
    }

    It 'should handle special characters correctly' {
        $specialChars = [System.Text.Encoding]::UTF8.GetBytes("Th!s 1s @ t3st")
        $result = ConvertTo-Base64String -InputObject $specialChars
        $result | Should -Be "VGghcyAxc0AjIHQzc3Q="
    }
}

