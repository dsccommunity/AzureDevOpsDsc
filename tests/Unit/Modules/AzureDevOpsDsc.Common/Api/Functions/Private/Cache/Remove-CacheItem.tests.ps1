Describe 'Remove-CacheItem' {
    BeforeEach {
        Function Get-CacheObject {
            param ([string]$CacheType)
            switch ($CacheType){
                "Project" { return [System.Collections.Generic.List[PSCustomObject]]@(
                    [PSCustomObject]@{ Key = "myKey"; Value = "someValue" }
                )}
                "Group" { return [System.Collections.Generic.List[PSCustomObject]]@(
                    [PSCustomObject]@{ Key = "anotherKey"; Value = "anotherValue" }
                )}
                default { throw "Invalid CacheType" }
            }
        }

        Function Set-Variable {}
    }

    It 'Removes item from Project cache when key matches' {
        $cache = Get-CacheObject -CacheType "Project"
        Remove-CacheItem -Key "myKey" -Type "Project"
        $global:AzDoProject | Should -BeNullOrEmpty
    }

    It 'Removes item from Group cache when key matches' {
        $cache = Get-CacheObject -CacheType "Group"
        Remove-CacheItem -Key "anotherKey" -Type "Group"
        $global:AzDoGroup | Should -BeNullOrEmpty
    }

    It 'Handles non-matching key correctly' {
        $cache = Get-CacheObject -CacheType "Group"
        $newCache = $cache.Clone()
        Remove-CacheItem -Key "nonMatchingKey" -Type "Group"
        $global:AzDoGroup | Should -ContainSameElementsAs $newCache
    }

    It 'Validates Type parameter against cache objects' {
        Get-AzDoCacheObjects = { return @('Project', 'Group', 'Team', 'SecurityDescriptor') }
        { Remove-CacheItem -Key "sampleKey" -Type "InvalidType" } | Should -Throw
    }

    AfterEach {
        Remove-Variable -Name "global:AzDoProject" -ErrorAction SilentlyContinue
        Remove-Variable -Name "global:AzDoGroup" -ErrorAction SilentlyContinue
        Remove-Variable -Name "global:AzDoTeam" -ErrorAction SilentlyContinue
        Remove-Variable -Name "global:AzDoSecurityDescriptor" -ErrorAction SilentlyContinue
    }
}

