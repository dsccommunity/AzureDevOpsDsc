$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-CacheObject' -Tags "Unit", "Cache" {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-CacheObject.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Project', 'Team', 'Group', 'SecurityDescriptor') }
        Mock -CommandName Export-CacheObject -MockWith {}

    }

    AfterAll {
        Remove-Variable -Name AzDoProject -ErrorAction SilentlyContinue
    }

    Context 'When setting Project cache' {

        It 'should set the global variable AzDoProject' {
            $content = @('Project1', 'Project2')
            $global:AzDoProject = $null

            Set-CacheObject -CacheType 'Project' -Content $content -Depth 2

            $global:AzDoProject | Should -Be $content
        }

        It 'should call Export-CacheObject with correct parameters' {
            $content = @('Project1', 'Project2')

            Set-CacheObject -CacheType 'Project' -Content $content -Depth 2

            Assert-MockCalled Export-CacheObject -Exactly -Times 1 -ParameterFilter {
                $CacheType -eq 'Project' -and
                $Depth -eq 2
            }
        }

        It 'should throw an error if CacheType is invalid' {
            { Set-CacheObject -CacheType 'InvalidType' -Content @('data') } | Should -Throw
        }

        It 'should throw an error if Export-CacheObject fails' {
            Mock -CommandName Export-CacheObject -MockWith { throw "Export failed" }
            Mock -CommandName Write-Error -Verifiable

            { Set-CacheObject -CacheType 'Project' -Content @('data') } | Should -Throw
        }
    }
}
