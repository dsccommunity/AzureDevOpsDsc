powershell
Describe 'Get-xAzDoOrganizationGroup' {
    Mock Get-CacheItem { return $null }

    Context 'When group is present in live cache and local cache with same originId' {
        BeforeAll {
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'LiveGroups' } {
                @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'Group' } {
                @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
        }

        It 'should return unchanged status if properties match' {
            $result = Get-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'Unchanged'
            $result.Ensure | Should -Be 'Present'
        }

        It 'should return changed status if properties differ' {
            $result = Get-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'New Description'
            $result.status | Should -Be 'Changed'
            $result.propertiesChanged | Should -Contain 'Description'
        }
    }

    Context 'When group is renamed' {
        BeforeAll {
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'LiveGroups' } {
                @{ originId = '123'; description = 'Test Group'; name = 'NewTestGroup' }
            }
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'Group' } {
                @{ originId = '456'; description = 'Test Group'; name = 'OldTestGroup' }
            }
        }

        It 'should detect renamed group' {
            $result = Get-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'Renamed'
            $result.renamedGroup.name | Should -Be 'NewTestGroup'
        }
    }

    Context 'When group is missing in live cache but present in local cache' {
        BeforeAll {
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'LiveGroups' } {
                return $null
            }
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'Group' } {
                @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
        }

        It 'should return not found status' {
            $result = Get-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'NotFound'
            $result.propertiesChanged | Should -Be @('description', 'displayName')
        }
    }

    Context 'When group is present in live cache but missing in local cache' {
        BeforeAll {
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'LiveGroups' } {
                @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'Group' } {
                return $null
            }
        }

        It 'should return unchanged if properties match' {
            $result = Get-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'Unchanged'
        }

        It 'should return changed if properties differ' {
            $result = Get-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'New Description'
            $result.status | Should -Be 'Changed'
            $result.propertiesChanged | Should -Contain 'description'
        }
    }

    Context 'When both live cache and local cache are missing the group' {
        BeforeAll {
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'LiveGroups' } {
                return $null
            }
            Mock Get-CacheItem -ParameterFilter { $Key -eq 'Group' } {
                return $null
            }
        }

        It 'should return not found status' {
            $result = Get-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'NotFound'
            $result.propertiesChanged | Should -Be @('description', 'displayName')
        }
    }
}

