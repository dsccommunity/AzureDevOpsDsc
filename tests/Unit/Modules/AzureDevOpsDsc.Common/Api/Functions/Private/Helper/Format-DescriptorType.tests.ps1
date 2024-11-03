$currentFile = $MyInvocation.MyCommand.Path

Describe 'Format-DescriptorType' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Format-DescriptorType.tests.ps1"
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }


    It 'returns "Git Repositories" for DescriptorType "GitRepositories"' {
        $result = Format-DescriptorType -DescriptorType 'GitRepositories'
        $result | Should -Be 'Git Repositories'
    }

    It 'returns the same value for DescriptorType "APIServices"' {
        $result = Format-DescriptorType -DescriptorType 'APIServices'
        $result | Should -Be 'APIServices'
    }

    It 'returns the same value for DescriptorType "Webhooks"' {
        $result = Format-DescriptorType -DescriptorType 'Webhooks'
        $result | Should -Be 'Webhooks'
    }

}
