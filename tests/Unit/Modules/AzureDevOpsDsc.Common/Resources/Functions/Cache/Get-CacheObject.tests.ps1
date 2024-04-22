
Describe 'Get-CacheObject' {
    Mock Import-CacheObject {
        return @{ Name = "ImportedCacheObject"; CacheType = $CacheType }
    }

    BeforeAll {
        # Set up a mock environment variable for the cache directory path
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
    }

    AfterAll {
        # Clean up the environment variable after tests
        $Env:AZDODSC_CACHE_DIRECTORY = $null
    }

    It 'Retrieves the cache object from memory if available' {
        New-Variable -Name "AzDoProject" -Value @{ Name = "InMemoryCacheObject"; CacheType = "Project" } -Scope Global
        $result = Get-CacheObject -CacheType 'Project'
        $result.Name | Should -BeExactly 'InMemoryCacheObject'
        Remove-Variable -Name "AzDoProject" -Scope Global
    }

    It 'Imports the cache object if not available in memory' {
        $result = Get-CacheObject -CacheType 'Team'
        $result.Name | Should -BeExactly 'ImportedCacheObject'
        $result.CacheType | Should -BeExactly 'Team'
    }

    It 'Throws an error if the AZDODSC_CACHE_DIRECTORY environment variable is not set' {
        Remove-Item Env:\AZDODSC_CACHE_DIRECTORY
        { Get-CacheObject -CacheType 'Group' } | Should -Throw -ExpectedMessage "*environment variable 'AZDODSC_CACHE_DIRECTORY' is not set*"
    }

    It 'Handles exceptions thrown during cache retrieval' {
        Mock Get-Variable { throw 'An error occurred while retrieving the variable.' }
        { Get-CacheObject -CacheType 'SecurityDescriptor' } | Should -Throw
    }

    It 'Validates that the CacheType parameter only accepts predefined values' {
        { Get-CacheObject -CacheType 'InvalidType' } | Should -Throw -ExpectedMessage '*does not belong to the ValidateSet attribute*'
    }
}
