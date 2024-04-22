Describe 'Initialize-CacheObject' {
    Mock Test-Path {
        return $false
    }

    Mock New-Item {}

    Mock Remove-Item {}

    BeforeAll {
        # Set up a mock environment variable for the cache directory path
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
        Mock Import-CacheObject {}
        Mock Set-CacheObject {}
    }

    AfterEach {
        # Clean up any set variables after each test
        Get-Variable -Name "AzDo*" -Scope Global -ErrorAction SilentlyContinue | Remove-Variable -Scope Global
    }

    It 'Creates a new cache object if the cache file does not exist' {
        Initialize-CacheObject -CacheType 'Project'
        Assert-MockCalled Set-CacheObject -Exactly 1 -Scope It
        Assert-MockCalled New-Item -Exactly 0 -Scope It # Directory already exists in this scenario
    }

    It 'Initializes cache from an existing cache file' {
        Mock Test-Path { return $true }
        Initialize-CacheObject -CacheType 'Team'
        Assert-MockCalled Import-CacheObject -Exactly 1 -Scope It
    }

    It 'Throws an error if the AZDODSC_CACHE_DIRECTORY environment variable is not set' {
        Remove-Item Env:\AZDODSC_CACHE_DIRECTORY
        { Initialize-CacheObject -CacheType 'Group' } | Should -Throw -ExpectedMessage "*environment variable 'AZDODSC_CACHE_DIRECTORY' is not set*"
    }

    It 'Creates the cache directory if it does not exist' {
        Mock Test-Path { param($Path) $Path -eq $cacheFilePath }
        Initialize-CacheObject -CacheType 'SecurityDescriptor'
        Assert-MockCalled New-Item -Exactly 1 -Scope It
        Assert-MockCalled Set-CacheObject -Exactly 1 -Scope It
    }

    It 'Removes existing live cache files if BypassFileCheck is not present' {
        Mock Test-Path { return $true }
        Initialize-CacheObject -CacheType 'LiveGroups'
        Assert-MockCalled Remove-Item -Exactly 1 -Scope It
    }

    It 'Does not remove live cache files if BypassFileCheck is present' {
        Mock Test-Path { return $true }
        Initialize-CacheObject -CacheType 'LiveProjects' -BypassFileCheck
        Assert-MockCalled Remove-Item -Exactly 0 -Scope It
    }

    It 'Validates that the CacheType parameter only accepts predefined values' {
        { Initialize-CacheObject -CacheType 'InvalidType' } | Should -Throw -ExpectedMessage '*does not belong to the ValidateSet attribute*'
    }
}


