$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-AzDoCacheObjects' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Get-AzDoCacheObjects.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }
    }

    It 'Returns an array with 13 elements' {
        $result = Get-AzDoCacheObjects
        $result.Length | Should -Be 13
    }

    It 'Contains expected elements' {
        $expectedElements = @(
            'Project',
            'Team',
            'Group',
            'SecurityDescriptor',
            'LiveGroups',
            'LiveProjects',
            'LiveUsers',
            'LiveGroupMembers',
            'LiveRepositories',
            'LiveServicePrinciples',
            'LiveACLList',
            'LiveProcesses',
            'SecurityNamespaces'
        )
        $result = Get-AzDoCacheObjects
        $result | Should -Be $expectedElements
    }
}
