powershell
Describe 'AzDoAPI_0_ProjectCache' {
    Mock List-DevOpsProjects {
        return @( @{ Id = 1; Name = 'Project1' }, @{ Id = 2; Name = 'Project2' } )
    }

    Mock Get-DevOpsSecurityDescriptor {
        return 'SecurityDescriptor'
    }

    Mock Add-CacheItem
    Mock Export-CacheObject

    Context 'When OrganizationName is provided' {
        It 'should call List-DevOpsProjects with provided OrganizationName' {
            AzDoAPI_0_ProjectCache -OrganizationName 'MyOrg'
            
            Assert-MockCalled List-DevOpsProjects -ParameterFilter { $params.Organization -eq 'MyOrg' } -Exactly 1
        }

        It 'should add projects to cache' {
            AzDoAPI_0_ProjectCache -OrganizationName 'MyOrg'
            
            Assert-MockCalled Add-CacheItem -Exactly 2
        }

        It 'should call Export-CacheObject' {
            AzDoAPI_0_ProjectCache -OrganizationName 'MyOrg'
            
            Assert-MockCalled Export-CacheObject -Exactly 1
        }
    }

    Context 'When OrganizationName is not provided' {
        $Global:DSCAZDO_OrganizationName = 'GlobalOrg'

        It 'should use global variable for OrganizationName' {
            AzDoAPI_0_ProjectCache
            
            Assert-MockCalled List-DevOpsProjects -ParameterFilter { $params.Organization -eq 'GlobalOrg' } -Exactly 1
        }
    }

    Context 'Error handling' {
        Mock List-DevOpsProjects { throw 'API Error' }

        It 'should handle API errors' {
            { AzDoAPI_0_ProjectCache -OrganizationName 'MyOrg' } | Should -Throw 'API Error'
        }
    }
}

