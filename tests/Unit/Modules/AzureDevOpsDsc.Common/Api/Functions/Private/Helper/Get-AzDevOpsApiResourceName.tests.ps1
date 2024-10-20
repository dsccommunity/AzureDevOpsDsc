$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-AzDevOpsApiResourceName' {

    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Get-AzDevOpsApiResourceName.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }
    }

    It 'Should return expected resource names' {
        $expected = @('Operation', 'Project')
        $result = Get-AzDevOpsApiResourceName
        $result | Should -Be $expected
    }

}
