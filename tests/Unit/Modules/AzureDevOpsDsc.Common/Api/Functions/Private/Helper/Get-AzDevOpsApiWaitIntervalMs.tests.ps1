$currentFile = $MyInvocation.MyCommand.Path

Describe "Get-AzDevOpsApiWaitIntervalMs" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Get-AzDevOpsApiWaitIntervalMs.tests.ps1"
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }
    }

    It "Should return an integer" {
        $result = Get-AzDevOpsApiWaitIntervalMs
        $result | Should -BeOfType 'System.Int32'
    }

    It "Should return 500" {
        $result = Get-AzDevOpsApiWaitIntervalMs
        $result | Should -Be 500
    }
}
