$currentFile = $MyInvocation.MyCommand.Path

Describe 'Test-AzDevOpsApiUri' {

    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDevOpsApiUri.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }
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

    It 'Throws an exception if -IsValid is not used' -skip {
        { Test-AzDevOpsApiUri -ApiUri 'http://example.com/_apis/' } | Should -Throw
    }
}
