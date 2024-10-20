$currentFile = $MyInvocation.MyCommand.Path

Describe 'Format-ACEs' -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Format-ACEs.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'SecurityNamespace' } -MockWith {
            return @{
                Key = 'SecurityNamespace'
                Type = 'SecurityNamespaces'
                Actions = @(
                    [PSCustomObject]@{ bit = 1; Name = 'Read' },
                    [PSCustomObject]@{ bit = 2; Name = 'Write' }
                )
            }
        }
    }

    It 'Returns Allow actions from the specified security namespace' {
        $result = Format-ACEs -Allow 1 -Deny 0 -SecurityNamespace "SecurityNamespace"

        $result.Allow.bit | Should -Be 1
        $result.Allow.Name | Should -Be 'Read'
        $result.Deny | Should -BeNullOrEmpty
        $result.DescriptorType | Should -Be "SecurityNamespace"
    }

    It 'Returns Deny actions from the specified security namespace' {
        $result = Format-ACEs -Allow 0 -Deny 2 -SecurityNamespace "SecurityNamespace"

        $result.Allow | Should -BeNullOrEmpty
        $result.Deny.bit | Should -Be 2
        $result.Deny.Name | Should -Be 'Write'
        $result.DescriptorType | Should -Be "SecurityNamespace"
    }

    It 'Returns both Allow and Deny actions from the specified security namespace' {
        $result = Format-ACEs -Allow 1 -Deny 2 -SecurityNamespace "SecurityNamespace"

        $result.Allow.bit | Should -Be 1
        $result.Allow.Name | Should -Be 'Read'
        $result.Deny.bit | Should -Be 2
        $result.Deny.Name | Should -Be 'Write'
        $result.DescriptorType | Should -Be "SecurityNamespace"
    }

}
