powershell
Describe 'Set-xAzDoProjectGroup Tests' {
    
    $GroupName = "TestGroup"
    $GroupDescription = "Description"
    $ProjectName = "TestProject"
    $SampleLookupResult = @{
        Status = [DSCGetSummaryState]::Good
        liveCache = @{
            descriptor = "someDescriptor"
            principalName = "LivePrincipal"
        }
        localCache = @{
            principalName = "LocalPrincipal"
        }
    }

    Mock Set-DevOpsGroup {
        return @{
            principalName = "NewPrincipal"
        }
    }

    Mock Remove-CacheItem {}
    Mock Add-CacheItem {}
    Mock Set-CacheObject {}
    Mock Write-Warning {}

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = "Organization"
        $Global:AZDOLiveGroups = @{}
        $Global:AzDoGroup = @{}
    }

    It 'Should call Write-Warning and return when LookupResult.Status is Renamed' {
        $SampleLookupResult.Status = [DSCGetSummaryState]::Renamed
        Set-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName -LookupResult $SampleLookupResult -Ensure "Present"
        
        Assert-MockCalled Write-Warning -Exactly 1 -Scope It
    }

    It 'Should call Set-DevOpsGroup with proper parameters' {
        Set-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName -LookupResult $SampleLookupResult -Ensure "Present"

        Assert-MockCalled Set-DevOpsGroup -Exactly 1 -Scope It -ParameterFilter {
            $GroupName -eq "TestGroup" -and
            $GroupDescription -eq "Description" -and
            $_.GroupDescriptor -eq "someDescriptor"
        }
    }

    It 'Should call Remove-CacheItem and Add-CacheItem for liveCache with proper parameters' {
        Set-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName -LookupResult $SampleLookupResult -Ensure "Present"

        Assert-MockCalled Remove-CacheItem -Exactly 1 -Scope It -ParameterFilter {
            $_.Key -eq "LivePrincipal" -and
            $_.Type -eq "LiveGroups"
        }

        Assert-MockCalled Add-CacheItem -Exactly 1 -Scope It -ParameterFilter {
            $_.Key -eq "NewPrincipal" -and
            $_.Value.principalName -eq "NewPrincipal" -and
            $_.Type -eq "LiveGroups"
        }
    }

    It 'Should call Remove-CacheItem and Add-CacheItem for localCache with proper parameters' {
        Set-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName -LookupResult $SampleLookupResult -Ensure "Present"

        Assert-MockCalled Remove-CacheItem -Exactly 1 -Scope It -ParameterFilter {
            $_.Key -eq "LocalPrincipal" -and
            $_.Type -eq "Groups"
        }

        Assert-MockCalled Add-CacheItem -Exactly 1 -Scope It -ParameterFilter {
            $_.Key -eq "NewPrincipal" -and
            $_.Value.principalName -eq "NewPrincipal" -and
            $_.Type -eq "Groups"
        }
    }

    It 'Should return the new group' {
        $result = Set-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName -LookupResult $SampleLookupResult -Ensure "Present"
        $result.principalName | Should -Be "NewPrincipal"
    }
}

