. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

Describe 'Export-CacheObject' {
    Mock Write-Verbose {}
    Mock New-Item {}
    Mock Export-Clixml {}

    BeforeAll {
        # Define a dummy environment variable for testing purposes.
        $ENV:AZDODSC_CACHE_DIRECTORY = "C:\DummyCacheDirectory"
    }

    It 'Throws an error if the AZDODSC_CACHE_DIRECTORY environment variable is not set' {
        # Remove the environment variable for this test.
        Remove-Variable -Name 'AZDODSC_CACHE_DIRECTORY' -Scope Global -Force
        { Export-CacheObject -CacheType 'Project' -Content @() } | Should -Throw
        # Restore the environment variable after the test.
        $ENV:AZDODSC_CACHE_DIRECTORY = "C:\DummyCacheDirectory"
    }

    It 'Creates a new cache directory if it does not exist' {
        Mock Test-Path { return $false }
        Export-CacheObject -CacheType 'Team' -Content @()
        Assert-MockCalled New-Item -Times 1
    }

    It 'Does not create a cache directory if it already exists' {
        Mock Test-Path { return $true }
        Export-CacheObject -CacheType 'Group' -Content @()
        Assert-MockCalled New-Item -Times 0
    }

    It 'Exports content to a cache file with correct depth' {
        Mock Test-Path { return $true }
        $content = @('item1', 'item2')
        $depth = 5
        Export-CacheObject -CacheType 'SecurityDescriptor' -Content $content -Depth $depth
        Assert-MockCalled Export-Clixml -Times 1 -ParameterFilter {
            $Depth -eq $depth
        }
    }

    It 'Handles all valid types of cache objects' {
        Mock Test-Path { return $true }
        $validTypes = @('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')
        foreach ($type in $validTypes) {
            Export-CacheObject -CacheType $type -Content @()
        }
        Assert-MockCalled Export-Clixml -Exactly -Times $validTypes.Count
    }
}
