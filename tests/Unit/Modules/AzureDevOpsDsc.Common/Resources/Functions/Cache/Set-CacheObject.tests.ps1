
Describe 'Set-CacheObject' {
    Mock Export-CacheObject {}

    BeforeAll {
        $script:CacheRootPath = "C:\CacheDirectory"
        $script:projectDataSample = @(
            @{ Name = "Project1"; Id = 1 },
            @{ Name = "Project2"; Id = 2 }
        )
    }

    It 'Sets cache object for valid cache types with content' {
        Mock Set-Variable {}

        $cacheTypes = 'Project', 'Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects'
        foreach ($type in $cacheTypes) {
            Set-CacheObject -CacheType $type -Content $script:projectDataSample -Depth 2
            Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It -ParameterFilter { $CacheType -eq $type -and $Content -eq $script:projectDataSample -and $Depth -eq 2 }
            Assert-MockCalled Set-Variable -Exactly 1 -Scope It -ParameterFilter { $Name -eq "AzDo$type" -and $Value -eq $script:projectDataSample }
        }
    }

    It 'Handles exceptions thrown during setting the cache object' {
        Mock Export-CacheObject { throw "Error exporting cache object" }

        { Set-CacheObject -CacheType 'Project' -Content $script:projectDataSample } | Should -Throw "Error exporting cache object"
    }

    It 'Defaults to depth of 3 when not provided' {
        Mock Export-CacheObject {}

        Set-CacheObject -CacheType 'Project' -Content $script:projectDataSample
        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It -ParameterFilter { $Depth -eq 3 }
    }

    It 'Allows empty content collection' {
        Mock Set-Variable {}

        Set-CacheObject -CacheType 'Project' -Content @()
        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It -ParameterFilter { $Content.Count -eq 0 }
        Assert-MockCalled Set-Variable -Exactly 1 -Scope It -ParameterFilter { $Value.Count -eq 0 }
    }
}

