. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

Describe 'Import-CacheObject' {
    Mock Import-Clixml {
        return @(
            @{ Key = "Item1"; Value = "Value1" },
            @{ Key = "Item2"; Value = "Value2" }
        )
    }

    Mock Test-Path {
        return $true
    }

    BeforeAll {
        # Set up a mock environment variable for the cache directory path
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
    }

    AfterEach {
        # Clean up any set variables after each test
        Get-Variable -Name "AzDo*" -Scope Global -ErrorAction SilentlyContinue | Remove-Variable -Scope Global
    }

    It 'Imports the cache object and sets it in a global variable' {
        $CacheType = 'Project'
        Import-CacheObject -CacheType $CacheType
        $cacheVar = Get-Variable -Name "AzDo$CacheType" -Scope Global -ErrorAction SilentlyContinue
        $cacheVar.Value.Count | Should -Be 2
        $cacheVar.Value[0].Key | Should -BeExactly 'Item1'
        $cacheVar.Value[1].Value | Should -BeExactly 'Value2'
    }

    It 'Throws an error if the AZDODSC_CACHE_DIRECTORY environment variable is not set' {
        Remove-Item Env:\AZDODSC_CACHE_DIRECTORY
        { Import-CacheObject -CacheType 'Team' } | Should -Throw -ExpectedMessage "*environment variable 'AZDODSC_CACHE_DIRECTORY' is not set*"
    }

    It 'Writes a warning if the cache file does not exist' {
        Mock Test-Path { return $false }
        { Import-CacheObject -CacheType 'Group' } | Should -Throw
        Assert-MockCalled Test-Path -Exactly 1 -Scope It
        Assert-MockCalled Write-Warning -Exactly 1 -Scope It
    }

    It 'Handles exceptions thrown during import' {
        Mock Import-Clixml { throw 'An error occurred while importing Clixml.' }
        { Import-CacheObject -CacheType 'SecurityDescriptor' } | Should -Throw
    }

    It 'Validates that the CacheType parameter only accepts predefined values' {
        { Import-CacheObject -CacheType 'InvalidType' } | Should -Throw -ExpectedMessage '*does not belong to the ValidateSet attribute*'
    }
}

