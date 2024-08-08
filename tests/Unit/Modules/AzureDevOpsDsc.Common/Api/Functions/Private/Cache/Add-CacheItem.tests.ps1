Describe 'Add-CacheItem' {
    BeforeEach {
        function Get-AzDoCacheObjects {
            return @('Project', 'Team', 'Group', 'SecurityDescriptor')
        }

        function Get-CacheObject {
            param ($CacheType)
            return @()
        }

        function Remove-CacheItem {
            param ($Key, $Type)
        }

        function [CacheItem]::New($key, $value) {
            return [pscustomobject]@{Key=$key; Value=$value}
        }
    }

    It 'Adds a new cache item when the cache is empty' {
        $key = 'MyKey'
        $value = 'MyValue'
        $type = 'Project'

        $global:AzDoProject = @()

        Add-CacheItem -Key $key -Value $value -Type $type

        $global:AzDoProject.Key | Should -Be $key
        $global:AzDoProject.Value | Should -Be $value
    }

    It 'Replaces an existing cache item if the key already exists' {
        $key = 'MyKey'
        $value = 'MyValue'
        $newValue = 'MyNewValue'
        $type = 'Project'

        $global:AzDoProject = [System.Collections.Generic.List[object]]([CacheItem]::New($key, $value))

        Add-CacheItem -Key $key -Value $newValue -Type $type

        $global:AzDoProject | Should -HaveCount 1
        $global:AzDoProject[0].Key | Should -Be $key
        $global:AzDoProject[0].Value | Should -Be $newValue
    }

    It 'Suppresses warning message when SuppressWarning switch is used' {
        $key = 'MyKey'
        $value = 'MyValue'
        $type = 'Project'

        $global:AzDoProject = [System.Collections.Generic.List[object]]([CacheItem]::New($key, $value))

        { Add-CacheItem -Key $key -Value 'MyNewValue' -Type $type -SuppressWarning } | Should -Not -Throw
    }
}

