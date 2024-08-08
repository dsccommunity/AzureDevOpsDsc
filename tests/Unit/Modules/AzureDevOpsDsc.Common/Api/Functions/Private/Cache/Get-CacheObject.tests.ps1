Describe 'Get-CacheObject Tests' {
    Mock Get-AzDoCacheObjects  { return @('Project', 'Team', 'Group', 'SecurityDescriptor') }
    Mock Import-CacheObject

    BeforeAll {
        $originalEnvironment = Get-Variable -Name "ENV" -Scope Global -ErrorAction SilentlyContinue
        if (-not $originalEnvironment) {
            New-Variable -Name "ENV" -Value @{} -Scope Global
        }
        $mockEnvironment = @{
            'AZDODSC_CACHE_DIRECTORY' = 'C:\MockCacheDirectory'
        }
        Set-Variable -Name "ENV" -Value $mockEnvironment -Scope Global
    }

    AfterAll {
        if ($originalEnvironment) {
            Set-Variable -Name "ENV" -Value $originalEnvironment -Scope Global
        }
    }

    It 'Should throw error if environment variable is not set' {
        Remove-Variable -Name "ENV" -Scope Global -ErrorAction SilentlyContinue
        { Get-CacheObject -CacheType 'Project' } | Should -Throw "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the variable to the path of the cache directory."
    }

    It 'Should return cache object from memory if available' {
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
        Set-Variable -Name "AzDoProject" -Value "ProjectCache" -Scope Global
        $result = Get-CacheObject -CacheType 'Project'
        $result | Should -Be "ProjectCache"
        Remove-Variable -Name "AzDoProject" -Scope Global -ErrorAction SilentlyContinue
    }

    It 'Should import cache object if not available in memory' {
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
        Mock Import-CacheObject { return "ImportedProjectCache" }

        $result = Get-CacheObject -CacheType 'Project'
        $result | Should -Be "ImportedProjectCache"
    }
}

