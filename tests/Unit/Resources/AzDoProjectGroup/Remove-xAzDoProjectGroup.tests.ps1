<#
    .SYNOPSIS
        Tests for the 'Remove-xAzDoProjectGroup' function to ensure it behaves as expected.

    .DESCRIPTION
        The tests will verify that the function correctly removes groups, handles parameters,
        and updates the cache accordingly.
#>

Describe "Remove-xAzDoProjectGroup Tests" {

    Mock Remove-DevOpsGroup {}
    Mock Remove-CacheItem {}
    Mock Set-CacheObject {}

    BeforeEach {
        $GroupName = "Developers"
        $ProjectName = "ContosoProject"
        $GroupDescription = "A group of developers."
        $Ensure = [Ensure]::Absent
        $Force = $false
        $LookupResult = @{
            liveCache = @{
                Descriptor = "LiveGroupDescriptor"
                principalName = "[$ProjectName]$GroupName"
            }
            localCache = @{
                Descriptor = "LocalGroupDescriptor"
                principalName = "[$ProjectName]$GroupName"
            }
        }
    }

    It "Should remove a group using the live cache descriptor if available" {
        Remove-xAzDoProjectGroup -GroupName $GroupName -ProjectName $ProjectName -LookupResult $LookupResult

        Assert-MockCalled Remove-DevOpsGroup -ParameterFilter { $GroupDescriptor -eq $LookupResult.liveCache.Descriptor } -Times 1
    }

    It "Should fall back to the local cache descriptor if no live cache is found" {
        $LookupResult.liveCache = $null

        Remove-xAzDoProjectGroup -GroupName $GroupName -ProjectName $ProjectName -LookupResult $LookupResult

        Assert-MockCalled Remove-DevOpsGroup -ParameterFilter { $GroupDescriptor -eq $LookupResult.localCache.Descriptor } -Times 1
    }

    It "Should remove the group from 'LiveGroups' cache" {
        Remove-xAzDoProjectGroup -GroupName $GroupName -ProjectName $ProjectName -LookupResult $LookupResult

        Assert-MockCalled Remove-CacheItem -ParameterFilter { $Key -eq $LookupResult.liveCache.principalName -and $Type -eq 'LiveGroups' } -Times 1
    }

    It "Should update the global 'LiveGroups' cache object after removal" {
        Remove-xAzDoProjectGroup -GroupName $GroupName -ProjectName $ProjectName -LookupResult $LookupResult

        Assert-MockCalled Set-CacheObject -ParameterFilter { $CacheType -eq 'LiveGroups' } -Times 1
    }

    It "Should remove the group from 'Group' cache" {
        Remove-xAzDoProjectGroup -GroupName $GroupName -ProjectName $ProjectName -LookupResult $LookupResult

        Assert-MockCalled Remove-CacheItem -ParameterFilter { $Key -eq $LookupResult.liveCache.principalName -and $Type -eq 'Group' } -Times 1
    }

    It "Should update the global 'Group' cache object after removal" {
        Remove-xAzDoProjectGroup -GroupName $GroupName -ProjectName $ProjectName -LookupResult $LookupResult

        Assert-MockCalled Set-CacheObject -ParameterFilter { $CacheType -eq 'Group' } -Times 1
    }

    It "Should not attempt removal if both liveCache and localCache are null" {
        $LookupResult.liveCache = $null
        $LookupResult.localCache = $null

        Remove-xAzDoProjectGroup -GroupName $GroupName -ProjectName $ProjectName -LookupResult $LookupResult

        Assert-MockCalled Remove-DevOpsGroup -Times 0
        Assert-MockCalled Remove-CacheItem -Times 0
        Assert-MockCalled Set-CacheObject -Times 0
    }
}
