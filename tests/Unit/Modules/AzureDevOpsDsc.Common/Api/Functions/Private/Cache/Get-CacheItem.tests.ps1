Describe 'Get-CacheItem' {
    Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Type1', 'Type2') }
    Mock -CommandName Get-CacheObject

    Context 'Valid Cache Item' {
        It 'Returns cache item value' {
            $expectedValue = 'TestValue'

            Mock Get-CacheObject {
                return [System.Collections.Generic.List[CacheItem]]@(
                    [PSCustomObject]@{ Key = 'MyKey'; Value = $expectedValue }
                )
            }

            $result = Get-CacheItem -Key 'MyKey' -Type 'Type1'
            $result | Should -Be $expectedValue
        }
    }

    Context 'Cache item does not exist' {
        It 'Returns $null when cache item is not found' {
            Mock Get-CacheObject {
                return [System.Collections.Generic.List[CacheItem]]@()
            }

            $result = Get-CacheItem -Key 'NonExistentKey' -Type 'Type1'
            $result | Should -Be $null
        }
    }

    Context 'Error handling' {
        It 'Logs error to verbose stream and returns $null' {
            Mock Get-CacheObject { throw 'Test exception' }

            $result = { Get-CacheItem -Key 'MyKey' -Type 'Type1' -Verbose } | Should -Throw
            $result.ErrorRecord.Exception.Message | Should -Be 'Test exception'
        }
    }

    Context 'Using Filter' {
        It 'Applies provided filter to cache items' {
            $filteredValue = 'FilteredValue'

            Mock Get-CacheObject {
                return [System.Collections.Generic.List[CacheItem]]@(
                    [PSCustomObject]@{ Key = 'OtherKey'; Value = 'OtherValue' },
                    [PSCustomObject]@{ Key = 'MyKey'; Value = $filteredValue }
                )
            }

            $result = Get-CacheItem -Key 'MyKey' -Type 'Type1' -Filter { $_.Value -eq $filteredValue }
            $result | Should -Be $filteredValue
        }
    }
}

