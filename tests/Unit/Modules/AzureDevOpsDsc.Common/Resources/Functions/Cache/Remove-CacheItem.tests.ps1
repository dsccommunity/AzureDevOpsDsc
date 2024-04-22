Describe 'Remove-CacheItem' {
    Mock Get-CacheObject {}
    Mock Set-Variable {}

    BeforeAll {
        # Define a sample cache list with CacheItem objects
        class CacheItem {
            [string]$Key
            [string]$Value
        }

        $sampleCache = [System.Collections.Generic.List[CacheItem]]::new()
        $item1 = [CacheItem]::new()
        $item1.Key = 'key1'
        $item1.Value = 'value1'
        $sampleCache.Add($item1)

        $item2 = [CacheItem]::new()
        $item2.Key = 'key2'
        $item2.Value = 'value2'
        $sampleCache.Add($item2)

        Mock Get-CacheObject { return $sampleCache }
    }

    It 'Removes an item by key from the cache when present' {
        Remove-CacheItem -Key 'key1' -Type 'Project'
        Assert-MockCalled Set-Variable -Exactly 1 -Scope It
        $global:AzDoProject.Count | Should -Be 1
        $global:AzDoProject[0].Key | Should -Be 'key2'
    }

    It 'Does not alter cache when key is not present' {
        Remove-CacheItem -Key 'nonExistentKey' -Type 'Team'
        Assert-MockCalled Set-Variable -Exactly 1 -Scope It
        $global:AzDoTeam.Count | Should -Be 2
    }

    It 'Clears the cache if it only contains one item matching the key' {
        $oneItemCache = [System.Collections.Generic.List[CacheItem]]::new()
        $oneItemCache.Add($item1)
        Mock Get-CacheObject { return $oneItemCache }

        Remove-CacheItem -Key 'key1' -Type 'Group'
        Assert-MockCalled Set-Variable -Exactly 1 -Scope It
        $global:AzDoGroup.Count | Should -Be 0
    }

    It 'Validates that the Type parameter only accepts predefined values' {
        { Remove-CacheItem -Key 'key1' -Type 'InvalidType' } | Should -Throw -ExpectedMessage "*does not belong to the ValidateSet attribute*"
    }
}

