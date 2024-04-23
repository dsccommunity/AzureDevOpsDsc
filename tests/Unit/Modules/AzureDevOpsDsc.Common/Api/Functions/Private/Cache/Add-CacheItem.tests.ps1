. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

Describe 'Add-CacheItem' {
    Mock Get-CacheObject { return [System.Collections.Generic.List[CacheItem]]::new() }
    Mock Set-Variable {}
    Mock Remove-CacheItem {}

    # Define a dummy CacheItem class for testing purposes.
    class CacheItem {
        [string]$Key
        [object]$Value
        CacheItem([string]$key, [object]$value) {
            $this.Key = $key
            $this.Value = $value
        }
    }

    BeforeEach {
        # Resetting the mock calls before each test
        Mock Get-CacheObject { return [System.Collections.Generic.List[CacheItem]]::new() }
    }

    It 'Adds a new cache item when cache is empty' {
        Add-CacheItem -Key 'NewKey' -Value 'NewValue' -Type 'Project'
        Assert-MockCalled Set-Variable -Times 1
    }

    It 'Does not add a duplicate cache item' {
        Mock Get-CacheObject {
            $list = [System.Collections.Generic.List[CacheItem]]::new()
            $list.Add([CacheItem]::New('ExistingKey', 'ExistingValue'))
            return $list
        }
        Add-CacheItem -Key 'ExistingKey' -Value 'NewValue' -Type 'Team'
        Assert-MockCalled Remove-CacheItem -Times 1
        Assert-MockCalled Set-Variable -Times 1
    }

    It 'Adds a cache item when cache already contains other items' {
        Mock Get-CacheObject {
            $list = [System.Collections.Generic.List[CacheItem]]::new()
            $list.Add([CacheItem]::New('ExistingKey1', 'ExistingValue1'))
            $list.Add([CacheItem]::New('ExistingKey2', 'ExistingValue2'))
            return $list
        }
        Add-CacheItem -Key 'NewKey' -Value 'NewValue' -Type 'Group'
        Assert-MockCalled Set-Variable -Times 1
    }

    It 'Handles all valid types of cache items' {
        $validTypes = @('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')
        foreach ($type in $validTypes) {
            Add-CacheItem -Key "KeyFor$type" -Value "ValueFor$type" -Type $type
        }
        Assert-MockCalled Set-Variable -Exactly -Times $validTypes.Count
    }
}
