
Describe 'Remove-xAzDoOrganizationGroup Tests' {

    Mock Remove-DevOpsGroup
    Mock Remove-CacheItem
    Mock Set-CacheObject

    $Global:DSCAZDO_OrganizationName = "TestOrg"
    $Global:AZDOLiveGroups = "LiveGroupsContent"
    $Global:AzDoGroup = "GroupContent"
    $LookupResult = @{
        liveCache = @{
            Descriptor = "liveDescriptor"
            principalName = "livePrincipal"
        }
        localCache = @{
            Descriptor = "localDescriptor"
            principalName = "localPrincipal"
        }
    }

    Context 'When LookupResult has liveCache and localCache' {
        It 'Should call Remove-DevOpsGroup and cache related functions' {
            Remove-xAzDoOrganizationGroup -GroupName "TestGroup" -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 1
            Assert-MockCalled -CommandName Remove-CacheItem -Times 2
            Assert-MockCalled -CommandName Set-CacheObject -Times 2
        }
    }

    Context 'When LookupResult has only liveCache' {
        $LookupResult.localCache = $null
        It 'Should call Remove-DevOpsGroup and cache related functions' {
            Remove-xAzDoOrganizationGroup -GroupName "TestGroup" -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 1
            Assert-MockCalled -CommandName Remove-CacheItem -Times 2
            Assert-MockCalled -CommandName Set-CacheObject -Times 2
        }
    }

    Context 'When LookupResult has only localCache' {
        $LookupResult.liveCache = $null
        It 'Should call Remove-DevOpsGroup and cache related functions' {
            Remove-xAzDoOrganizationGroup -GroupName "TestGroup" -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 1
            Assert-MockCalled -CommandName Remove-CacheItem -Times 2
            Assert-MockCalled -CommandName Set-CacheObject -Times 2
        }
    }

    Context 'When LookupResult is empty' {
        $LookupResult = @{
            liveCache = $null
            localCache = $null
        }
        It 'Should not call Remove-DevOpsGroup or cache related functions' {
            Remove-xAzDoOrganizationGroup -GroupName "TestGroup" -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 0
            Assert-MockCalled -CommandName Remove-CacheItem -Times 0
            Assert-MockCalled -CommandName Set-CacheObject -Times 0
        }
    }
}

