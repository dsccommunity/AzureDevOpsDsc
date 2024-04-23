. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

Describe 'Find-CacheItem' {
    Mock Write-Verbose {}

    It 'Finds a cache item with a specific name' {
        $cacheItems = @(
            @{ Name = 'MyCacheItem'; Value = 'Data1' },
            @{ Name = 'OtherCacheItem'; Value = 'Data2' }
        )

        $filterScript = { $_.Name -eq 'MyCacheItem' }
        $result = $cacheItems | Find-CacheItem -Filter $filterScript

        $result.Name | Should -BeExactly 'MyCacheItem'
        $result.Value | Should -BeExactly 'Data1'
    }

    It 'Returns $null if no cache item matches the filter' {
        $cacheItems = @(
            @{ Name = 'CacheItem1'; Value = 'Data1' },
            @{ Name = 'CacheItem2'; Value = 'Data2' }
        )

        $filterScript = { $_.Name -eq 'NonExistentItem' }
        $result = $cacheItems | Find-CacheItem -Filter $filterScript

        $result | Should -Be $null
    }

    It 'Can handle multiple items and return the first match' {
        $cacheItems = @(
            @{ Name = 'DuplicateItem'; Value = 'First' },
            @{ Name = 'DuplicateItem'; Value = 'Second' }
        )

        $filterScript = { $_.Name -eq 'DuplicateItem' }
        $result = $cacheItems | Find-CacheItem -Filter $filterScript

        $result.Value | Should -BeExactly 'First'
    }

    It 'Can handle an empty list of cache items' {
        $cacheItems = @()

        $filterScript = { $_.Name -eq 'AnyItem' }
        $result = $cacheItems | Find-CacheItem -Filter $filterScript

        $result | Should -Be $null
    }

    It 'Can handle complex filter script blocks' {
        $cacheItems = @(
            @{ Name = 'ItemA'; Type = 'Type1'; Value = 'A1' },
            @{ Name = 'ItemB'; Type = 'Type2'; Value = 'B1' },
            @{ Name = 'ItemC'; Type = 'Type1'; Value = 'C1' }
        )

        $filterScript = { $_.Type -eq 'Type1' -and $_.Value -like 'C*' }
        $result = $cacheItems | Find-CacheItem -Filter $filterScript

        $result.Name | Should -BeExactly 'ItemC'
        $result.Type | Should -BeExactly 'Type1'
        $result.Value | Should -BeExactly 'C1'
    }
}
