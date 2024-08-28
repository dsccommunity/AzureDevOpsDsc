
Describe 'Get-xAzDoProjectGroup' {
    Mock Get-CacheItem
    Mock Remove-CacheItem
    Mock Add-CacheItem
    Mock Format-AzDoGroup

    $mockProjectName = "TestProject"
    $mockGroupName = "TestGroup"
    $mockDescription = "TestDescription"

    It 'should call Get-CacheItem for livegroup lookup' {
        Get-xAzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName
        Assert-MockCalled Get-CacheItem -ParameterFilter { $_.Key -eq "$mockProjectName" -and $_.Type -eq 'LiveProjects' } -Times 1
    }

    It 'should return correct status when livegroup and localgroup originId differ' {
        Mock Get-CacheItem { return @{originId = 1} }
        Mock Format-AzDoGroup { return "$mockProjectName:$mockGroupName" }

        $result = Get-xAzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName

        $result.status | Should -Be 'Renamed'
    }

    It 'should return status NotFound when livegroup is absent but localgroup is present' {
        Mock Get-CacheItem {
            param ($Key, $Type)
            if ($Type -eq 'LiveGroups') { return $null }
            if ($Type -eq 'Group') { return @{originId = 1} }
        }

        Mock Format-AzDoGroup { return "$mockProjectName:$mockGroupName" }

        $result = Get-xAzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName

        $result.status | Should -Be 'NotFound'
    }

    It 'should return status Changed when properties differ' {
        Mock Get-CacheItem {
            return @{description = 'OldDescription'; name = $mockGroupName; originId = 1}
        }
        Mock Format-AzDoGroup { return "$mockProjectName:$mockGroupName" }

        $result = Get-xAzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName -GroupDescription $mockDescription

        $result.status | Should -Be 'Changed'
        $result.propertiesChanged | Should -Contain 'description'
    }

    It 'should return status Unchanged when properties are same' {
        Mock Get-CacheItem {
            return @{description = $mockDescription; name = $mockGroupName; originId = 1}
        }
        Mock Format-AzDoGroup { return "$mockProjectName:$mockGroupName" }

        $result = Get-xAzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName -GroupDescription $mockDescription

        $result.status | Should -Be 'Unchanged'
    }

    It 'should add current livegroup to cache if localgroup was not present' {
        Mock Get-CacheItem {
            param ($Key, $Type)
            if ($Type -eq 'LiveGroups') { return @{description = $mockDescription; displayName = $mockGroupName; originId = 1} }
            else { return $null }
        }
        Mock Format-AzDoGroup { return "$mockProjectName:$mockGroupName" }

        Get-xAzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName

        Assert-MockCalled Add-CacheItem -ParameterFilter { $_.Key -eq "$mockProjectName:$mockGroupName" -and $_.Type -eq 'Group' } -Times 1
    }
}

