$currentFile = $MyInvocation.MyCommand.Path

Describe 'Format-ACEs' {

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

        Mock -ModuleName AzureDevOpsDsc.Common -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'SecurityNamespace' } -MockWith {
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

        $result.Allow | Should -Contain [PSCustomObject]@{ bit = 1; Name = 'Read' }
        $result.Allow | Should -Not -Contain [PSCustomObject]@{ bit = 2; Name = 'Write' }
        $result.Deny | Should -BeNullOrEmpty
        $result.DescriptorType | Should -Be "SecurityNamespace"
    }

    It 'Returns Deny actions from the specified security namespace' {
        $result = Format-ACEs -Allow 0 -Deny 2 -SecurityNamespace "SecurityNamespace"

        $result.Allow | Should -BeNullOrEmpty
        $result.Deny | Should -Contain [PSCustomObject]@{ bit = 2; Name = 'Write' }
        $result.Deny | Should -Not -Contain [PSCustomObject]@{ bit = 1; Name = 'Read' }
        $result.DescriptorType | Should -Be "SecurityNamespace"
    }

    It 'Returns both Allow and Deny actions from the specified security namespace' {
        $result = Format-ACEs -Allow 1 -Deny 2 -SecurityNamespace "SecurityNamespace"

        $result.Allow | Should -Contain [PSCustomObject]@{ bit = 1; Name = 'Read' }
        $result.Deny | Should -Contain [PSCustomObject]@{ bit = 2; Name = 'Write' }
        $result.DescriptorType | Should -Be "SecurityNamespace"
    }

    It 'Handles missing SecurityNamespace parameter as mandatory' {
        { Format-ACEs -Allow 1 -Deny 0 } | Should -Throw -ErrorId ParameterBindingValidationException
    }
}
