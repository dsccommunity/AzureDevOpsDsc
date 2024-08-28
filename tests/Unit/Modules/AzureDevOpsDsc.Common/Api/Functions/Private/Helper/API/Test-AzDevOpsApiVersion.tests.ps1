$currentFile = $MyInvocation.MyCommand.Path

Describe 'Test-AzDevOpsApiVersion' {
    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDevOpsApiVersion.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }
    }

    It 'Should return $true for supported API version' {
        $result = Test-AzDevOpsApiVersion -ApiVersion '6.0' -IsValid
        $result | Should -Be $true
    }

    It 'Should return $false for unsupported API version' {
        $result = Test-AzDevOpsApiVersion -ApiVersion '5.0' -IsValid
        $result | Should -Be $false
    }

}

