Describe 'AzDoAPI_6_ServicePrinciple' {
    BeforeEach {
        Mock List-DevOpsServicePrinciples {
            return @({'displayName' = 'SP1'}, {'displayName' = 'SP2'})
        }
        Mock Add-CacheItem
        Mock Export-CacheObject

        $Global:DSCAZDO_OrganizationName = 'MyOrganization'
    }

    It 'should call List-DevOpsServicePrinciples with provided organization name' {
        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName'

        Assert-MockCalled List-DevOpsServicePrinciples -Exactly 1 -Scope It -ParameterFilter { $Organization -eq 'TestOrgName' }
    }

    It 'should call List-DevOpsServicePrinciples with global organization name if none provided' {
        AzDoAPI_6_ServicePrinciple

        Assert-MockCalled List-DevOpsServicePrinciples -Exactly 1 -Scope It -ParameterFilter { $Organization -eq $Global:DSCAZDO_OrganizationName }
    }

    It 'should add returned service principals to cache' {
        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName'

        Assert-MockCalled Add-CacheItem -Exactly 2 -Scope It
        Assert-MockCalled Add-CacheItem -ParameterFilter { $Key -eq 'SP1' -and $Value.displayName -eq 'SP1' -and $Type -eq 'LiveServicePrinciples' }
        Assert-MockCalled Add-CacheItem -ParameterFilter { $Key -eq 'SP2' -and $Value.displayName -eq 'SP2' -and $Type -eq 'LiveServicePrinciples' }
    }

    It 'should export cache object after adding service principals' {
        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName'

        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It -ParameterFilter { $CacheType -eq 'LiveServicePrinciples' }
    }

    It 'should write an error message if an exception occurs' {
        Mock List-DevOpsServicePrinciples { throw 'API Error' }

        { AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName' } | Should -Throw

        Assert-MockCalled -CommandName Write-Error -Exactly 1 -Scope It
    }
}

