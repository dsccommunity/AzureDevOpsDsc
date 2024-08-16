
# Find-CacheItem.Tests.ps1

# Import the module or the script containing the function
# Import-Module 'Path\To\Your\Module.psd1' or . .\Path\To\YourScript.ps1

Describe 'Find-CacheItem' {
    $testCacheList = @(
        [PSCustomObject]@{ Name = 'Item1'; Value = 'Value1' },
        [PSCustomObject]@{ Name = 'Item2'; Value = 'Value2' },
        [PSCustomObject]@{ Name = 'MyCacheItem'; Value = 'Value3' }
    )

    Context 'When a matching item exists' {
        It 'Returns the matching item' {
            $filter = { $_.Name -eq 'MyCacheItem' }
            $result = $testCacheList | Find-CacheItem -Filter $filter
            $result | Should -HaveCount 1
            $result.Name | Should -Be 'MyCacheItem'
        }
    }

    Context 'When no matching item exists' {
        It 'Returns an empty array' {
            $filter = { $_.Name -eq 'NonExistentItem' }
            $result = $testCacheList | Find-CacheItem -Filter $filter
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'With an empty cache list' {
        It 'Returns an empty array' {
            $emptyCacheList = @()
            $filter = { $_.Name -eq 'AnyItem' }
            $result = $emptyCacheList | Find-CacheItem -Filter $filter
            $result | Should -BeNullOrEmpty
        }
    }
}

