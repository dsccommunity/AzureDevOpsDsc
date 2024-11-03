$currentFile = $MyInvocation.MyCommand.Path

Describe 'Test-AzDevOpsApiResourceId' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDevOpsApiResourceId.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    It 'Returns $true for a valid ResourceId' {
        $ValidResourceId = [guid]::NewGuid().ToString()
        $result = Test-AzDevOpsApiResourceId -ResourceId $ValidResourceId -IsValid
        $result | Should -Be $true
    }

    It 'Returns $false for an invalid ResourceId' {
        $InvalidResourceId = 'Invalid-GUID'
        $result = Test-AzDevOpsApiResourceId -ResourceId $InvalidResourceId -IsValid
        $result | Should -Be $false
    }

    It 'Throws exception if IsValid switch is not provided' -skip {
        $ValidResourceId = [guid]::NewGuid().ToString()
        { Test-AzDevOpsApiResourceId -ResourceId $ValidResourceId } | Should -Throw
    }
}
