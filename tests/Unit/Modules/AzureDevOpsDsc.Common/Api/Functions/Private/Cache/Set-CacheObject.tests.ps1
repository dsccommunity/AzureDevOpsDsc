Describe 'Set-CacheObject' {

    Mock Get-AzDoCacheObjects { return @('Project', 'Team', 'Group', 'SecurityDescriptor') }
    Mock Export-CacheObject {}

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

            Assert-MockCalled Export-CacheObject -Exactly -Times 1 -Scope It -ParameterFilter {
                $CacheType -eq 'Project' -and
                $Content -eq $content -and
                $Depth -eq 2
            }
        }

        It 'should throw an error if CacheType is invalid' {
            { Set-CacheObject -CacheType 'InvalidType' -Content @('data') } | Should -Throw
        }

        It 'should throw an error if Export-CacheObject fails' {
            Mock Export-CacheObject { throw "Export failed" }

            { Set-CacheObject -CacheType 'Project' -Content @('data') } | Should -Throw
        }
    }
}

