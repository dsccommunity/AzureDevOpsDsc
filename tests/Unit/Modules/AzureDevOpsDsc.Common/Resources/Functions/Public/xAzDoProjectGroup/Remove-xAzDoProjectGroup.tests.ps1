
Describe 'Remove-xAzDoProjectGroup Tests' {
    Mock Remove-DevOpsGroup
    Mock Remove-CacheItem
    Mock Set-CacheObject

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'DummyOrg'
        $Global:AZDOLiveGroups = @{}
        $Global:AzDoGroup = @{}
        $LookupResult = @{
            liveCache = [PSCustomObject]@{
                Descriptor = 'live-descriptor'
                principalName = 'live-principal'
            }
            localCache = [PSCustomObject]@{
                Descriptor = 'local-descriptor'
                principalName = 'local-principal'
            }
        }
    }

    It 'Removes group when liveCache is present' {
        Remove-xAzDoProjectGroup -GroupName 'Group1' -ProjectName 'Project1' -LookupResult $LookupResult -Ensure 'Present'
        Assert-MockCalled Remove-DevOpsGroup -Exactly 1 -Scope It -Parameters @{
            GroupDescriptor = 'live-descriptor'
            ApiUri = 'https://vssps.dev.azure.com/DummyOrg'
        }
        Assert-MockCalled Remove-CacheItem -Exactly 2 -Scope It -ParameterFilter {
            $_.Key -eq 'live-principal' -and $_.Type -eq 'LiveGroups'
        }
        Assert-MockCalled Set-CacheObject -Exactly 2 -Scope It
    }

    It 'Removes group when only localCache is present' {
        $LookupResult.liveCache = $null
        Remove-xAzDoProjectGroup -GroupName 'Group1' -ProjectName 'Project1' -LookupResult $LookupResult -Ensure 'Present'
        Assert-MockCalled Remove-DevOpsGroup -Exactly 1 -Scope It -Parameters @{
            GroupDescriptor = 'local-descriptor'
            ApiUri = 'https://vssps.dev.azure.com/DummyOrg'
        }
        Assert-MockCalled Remove-CacheItem -Exactly 2 -Scope It -ParameterFilter {
            $_.Key -eq 'local-principal' -and $_.Type -eq 'Group'
        }
        Assert-MockCalled Set-CacheObject -Exactly 2 -Scope It
    }

    It 'Returns when no cache items exist' {
        $LookupResult = @{
            liveCache = $null
            localCache = $null
        }
        Remove-xAzDoProjectGroup -GroupName 'Group1' -ProjectName 'Project1' -LookupResult $LookupResult -Ensure 'Present'
        Assert-MockCalled Remove-DevOpsGroup -Exactly 0 -Scope It
        Assert-MockCalled Remove-CacheItem -Exactly 0 -Scope It
        Assert-MockCalled Set-CacheObject -Exactly 0 -Scope It
    }
}

