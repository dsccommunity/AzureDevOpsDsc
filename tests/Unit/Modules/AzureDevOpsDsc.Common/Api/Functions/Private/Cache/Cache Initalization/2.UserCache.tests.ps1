Describe 'AzDoAPI_2_UserCache' {

    Mock -ModuleName <ModuleName> -CommandName List-UserCache {
        return @(
            [PSCustomObject]@{ PrincipalName = 'user1@example.com' },
            [PSCustomObject]@{ PrincipalName = 'user2@example.com' }
        )
    }

    Mock -ModuleName <ModuleName> -CommandName Add-CacheItem
    Mock -ModuleName <ModuleName> -CommandName Export-CacheObject

    Context 'when organization name parameter is provided' {

        It 'should call List-UserCache with correct parameters' {
            AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

            Assert-MockCalled -ModuleName <ModuleName> -CommandName List-UserCache -Exactly -Times 1 -Scope It -ParameterFilter {
                $Organization -eq 'TestOrg'
            }
        }

        It 'should add users to cache' {
            AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

            Assert-MockCalled -ModuleName <ModuleName> -CommandName Add-CacheItem -Exactly -Times 2
            Assert-MockCalled -ModuleName <ModuleName> -CommandName Add-CacheItem -ParameterFilter {
                $Key -eq 'user1@example.com'
            }
            Assert-MockCalled -ModuleName <ModuleName> -CommandName Add-CacheItem -ParameterFilter {
                $Key -eq 'user2@example.com'
            }
        }

        It 'should export the cache' {
            AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

            Assert-MockCalled -ModuleName <ModuleName> -CommandName Export-CacheObject -Exactly -Times 1
        }
    }

    Context 'when organization name parameter is not provided' {

        BeforeEach {
            $Global:DSCAZDO_OrganizationName = 'GlobalTestOrg'
        }

        It 'should use the global organization name' {
            AzDoAPI_2_UserCache

            Assert-MockCalled -ModuleName <ModuleName> -CommandName List-UserCache -Exactly -Times 1 -ParameterFilter {
                $Organization -eq 'GlobalTestOrg'
            }
        }
    }

    Context 'when an error occurs' {

        Mock -ModuleName <ModuleName> -CommandName List-UserCache { throw "API Error" }

        It 'should catch and handle the error' {
            { AzDoAPI_2_UserCache -OrganizationName 'TestOrg' } | Should -Throw

            Get-Variable -Name Error -Scope Global | Should -Not -BeNullOrEmpty
        }
    }
}

