powershell
Describe 'AzDoAPI_1_GroupCache' {
    Mock List-DevOpsGroups { return @(
        @{ PrincipalName = 'Group1'; OtherProperty = 'Value1' },
        @{ PrincipalName = 'Group2'; OtherProperty = 'Value2' }
    ) }
    
    Mock Add-CacheItem
    Mock Export-CacheObject

    Context 'When organization name is provided as parameter' {
        It 'should call List-DevOpsGroups with provided organization name' {
            $Global:DSCAZDO_OrganizationName = $null
            $organizationName = 'MyOrganization'
            AzDoAPI_1_GroupCache -OrganizationName $organizationName

            Assert-MockCalled List-DevOpsGroups -Exactly 1 -Scope It -ParameterFilter {
                $Organization -eq $organizationName
            }
        }

        It 'should add groups to cache and export cache' {
            AzDoAPI_1_GroupCache -OrganizationName "MyOrganization"

            Assert-MockCalled Add-CacheItem -Exactly 2 -Scope It
            Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It
        }
    }
    
    Context 'When organization name is not provided as parameter' {
        It 'should use global variable for organization name' {
            $Global:DSCAZDO_OrganizationName = 'GlobalOrganization'
            AzDoAPI_1_GroupCache

            Assert-MockCalled List-DevOpsGroups -Exactly 1 -Scope It -ParameterFilter {
                $Organization -eq $Global:DSCAZDO_OrganizationName
            }
        }
    }

    Context 'When there is an error during execution' {
        Mock List-DevOpsGroups { throw 'List-DevOpsGroups error' }

        It 'should catch and log the error using Write-Error' {
            $errorActionPreference = 'Stop'
            { AzDoAPI_1_GroupCache -OrganizationName "MyOrganization" } | Should -Throw

            $result = Get-Variable error -Scope 0
            $lastError = $result.value[0]

            $lastError.Exception.Message | Should -Match 'List-DevOpsGroups error'
        }
    }
}

