
Describe 'AzDoAPI_2_UserCache' {
    Mock List-UserCache {
        return @(
            [pscustomobject]@{ PrincipalName = 'user1@domain.com'; }
            [pscustomobject]@{ PrincipalName = 'user2@domain.com'; }
        )
    }

    Mock Add-CacheItem { }

    Mock Export-CacheObject { }

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
    }

    It 'Should call List-UserCache with correct parameters' {
        AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

        Assert-MockCalled List-UserCache -Exactly -Scope It -ParameterFilter { $Organization -eq 'TestOrg' }
    }

    It 'Should use global variable if OrganizationName is not provided' {
        AzDoAPI_2_UserCache

        Assert-MockCalled List-UserCache -Exactly -Scope It -ParameterFilter { $Organization -eq 'TestOrganization' }
    }

    It 'Should add returned users to cache' {
        AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

        Assert-MockCalled Add-CacheItem -Exactly 2 -Scope It
        Assert-MockCalled Add-CacheItem -Scope It -ParameterFilter { $Key -eq 'user1@domain.com' }
        Assert-MockCalled Add-CacheItem -Scope It -ParameterFilter { $Key -eq 'user2@domain.com' }
    }

    It 'Should export cache to file' {
        AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

        Assert-MockCalled Export-CacheObject -Exactly -Scope It -ParameterFilter { $CacheType -eq 'LiveUsers' -and $Content -eq $Global:AzDoLiveUsers }
    }

    It 'Should log error if an exception occurs' {
        Mock List-UserCache { throw 'Error' }

        { AzDoAPI_2_UserCache -OrganizationName 'TestOrg' } | Should -Throw

        # Check if Write-Error was called
        Assert-MockCalled Write-Error -Exactly 1 -Scope It
    }
}

