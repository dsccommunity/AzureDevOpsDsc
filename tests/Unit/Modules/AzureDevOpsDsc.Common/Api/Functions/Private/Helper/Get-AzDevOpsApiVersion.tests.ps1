$currentFile = $MyInvocation.MyCommand.Path
Describe 'Get-AzDevOpsApiVersion Tests' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Get-AzDevOpsApiVersion.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    It 'Should return all supported API versions when no parameters are specified' {
        $result = Get-AzDevOpsApiVersion
        $result.count | Should -BeGreaterThan 1
    }

    It 'Should return default API version when -Default is specified' {
        $expected = '7.0-preview.1'
        $result = Get-AzDevOpsApiVersion -Default
        $result | Should -Be $expected
    }

}

