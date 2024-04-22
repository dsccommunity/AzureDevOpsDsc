
Describe 'Set-AzDoAPICacheGroup' {
    Mock List-DevOpsGroups {}
    Mock Add-CacheItem {}
    Mock Export-CacheObject {}

    BeforeAll {
        $Global:DSCAZDO_OrganizationName = "DefaultOrg"
    }

    It 'Sets the group cache with provided organization name' {
        Mock List-DevOpsGroups { return @('Group1', 'Group2') }

        Set-AzDoAPICacheGroup -OrganizationName "CustomOrg"
        Assert-MockCalled List-DevOpsGroups -Exactly 1 -Scope It -ParameterFilter { $Organization -eq "CustomOrg" }
        Assert-MockCalled Add-CacheItem -Exactly 2 -Scope It
        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It
    }

    It 'Sets the group cache using global organization name when not provided' {
        Mock List-DevOpsGroups { return @('Group1', 'Group2') }

        Set-AzDoAPICacheGroup
        Assert-MockCalled List-DevOpsGroups -Exactly 1 -Scope It -ParameterFilter { $Organization -eq $Global:DSCAZDO_OrganizationName }
        Assert-MockCalled Add-CacheItem -Exactly 2 -Scope It
        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It
    }

    It 'Handles exceptions thrown during the process' {
        Mock List-DevOpsGroups { throw "Error retrieving groups" }

        { Set-AzDoAPICacheGroup -OrganizationName "FailingOrg" } | Should -Throw "Error retrieving groups"
    }
}
