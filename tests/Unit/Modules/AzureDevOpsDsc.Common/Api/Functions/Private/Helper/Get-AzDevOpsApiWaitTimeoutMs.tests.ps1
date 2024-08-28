$currentFile = $MyInvocation.MyCommand.Path

Describe "Get-AzDevOpsApiWaitTimeoutMs" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Get-AzDevOpsApiWaitTimeoutMs.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }
    }

    It "Should return 300000 milliseconds" {
        $result = Get-AzDevOpsApiWaitTimeoutMs
        $result | Should -Be 300000
    }
}
