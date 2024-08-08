Describe 'Export-CacheObject' {
    Mock Get-AzDoCacheObjects { return @('Project', 'Team', 'Group', 'SecurityDescriptor') }
    Mock Export-Clixml {}

    BeforeEach {
        $ENV:AZDODSC_CACHE_DIRECTORY = 'C:\Temp'
        Remove-Variable -Name AzDoProject -ErrorAction Ignore
    }

    It 'Exports content to a cache file' {
        $cacheType = 'Project'
        $content = @('Data1', 'Data2')

        Export-CacheObject -CacheType $cacheType -Content $content

        $cacheFilePath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "Cache\$cacheType.clixml"
        Test-Path $cacheFilePath | Should -Be $true
        Get-Content $cacheFilePath | Should -Contain 'Data1'
        Get-Content $cacheFilePath | Should -Contain 'Data2'
    }

    It 'Creates cache directory if it does not exist' {
        Remove-Item -Path $ENV:AZDODSC_CACHE_DIRECTORY -Recurse -Force -ErrorAction Ignore
        $cacheType = 'Team'
        $content = @('TeamData')

        Export-CacheObject -CacheType $cacheType -Content $content

        $cacheDirectoryPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "Cache"
        Test-Path $cacheDirectoryPath | Should -Be $true
    }

    It 'Throws an error if AZDODSC_CACHE_DIRECTORY is not set' {
        Remove-Item -Path Variable:\AZDODSC_CACHE_DIRECTORY -Force -ErrorAction Ignore
        { Export-CacheObject -CacheType 'Project' -Content @('Data') } | Should -Throw -ExceptionMessage "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set."
    }

    It 'Throws an error if invalid CacheType is provided' {
        { Export-CacheObject -CacheType 'InvalidType' -Content @('Data') } | Should -Throw
    }

    AfterEach {
        Remove-Variable -Name AZDODSC_CACHE_DIRECTORY -ErrorAction Ignore
    }
}

