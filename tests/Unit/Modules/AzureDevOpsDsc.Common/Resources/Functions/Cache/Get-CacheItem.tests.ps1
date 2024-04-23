. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

Describe 'Get-CacheItem' {
    BeforeAll {
        # Define a mock CacheItem class if it doesn't exist in the current context
        if (-not ([Type]::GetType('CacheItem'))) {
            class CacheItem {
                [string]$Key
                [string]$Value
            }
        }

        # Mock the Get-CacheObject function to return a list of CacheItems
        Mock Get-CacheObject {
            $cacheList = New-Object 'System.Collections.Generic.List[CacheItem]'
            $cacheList.Add((New-Object CacheItem -Property @{ Key = 'MyKey'; Value = 'MyValue' }))
            $cacheList.Add((New-Object CacheItem -Property @{ Key = 'OtherKey'; Value = 'OtherValue' }))
            return $cacheList
        }
    }

    It 'Retrieves the correct cache item by key' {
        $result = Get-CacheItem -Key 'MyKey' -Type 'Project'
        $result | Should -BeExactly 'MyValue'
    }

    It 'Returns $null if no matching key is found' {
        $result = Get-CacheItem -Key 'NonExistentKey' -Type 'Team'
        $result | Should -Be $null
    }

    It 'Applies an additional filter if provided' {
        $filterScript = { $_.Value -eq 'MyValue' }
        $result = Get-CacheItem -Key 'MyKey' -Type 'Group' -Filter $filterScript
        $result | Should -BeExactly 'MyValue'
    }

    It 'Returns $null if the additional filter excludes all items' {
        $filterScript = { $_.Value -eq 'NonExistentValue' }
        $result = Get-CacheItem -Key 'MyKey' -Type 'SecurityDescriptor' -Filter $filterScript
        $result | Should -Be $null
    }

    It 'Handles exceptions thrown by Get-CacheObject gracefully' {
        Mock Get-CacheObject { throw 'An error occurred.' }
        $result = Get-CacheItem -Key 'MyKey' -Type 'LiveGroups'
        $result | Should -Be $null
    }

    It 'Validates that the Type parameter only accepts predefined values' {
        { Get-CacheItem -Key 'MyKey' -Type 'InvalidType' } | Should -Throw -ExpectedMessage '*does not belong to the ValidateSet attribute*'
    }
}
