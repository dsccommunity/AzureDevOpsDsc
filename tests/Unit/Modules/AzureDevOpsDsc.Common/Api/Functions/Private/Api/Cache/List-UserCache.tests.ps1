Describe 'List-UserCache' {
    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{ id = 1; displayName = 'User One' }
                @{ id = 2; displayName = 'User Two' }
            )
        }
    }

    Mock Get-AzDevOpsApiVersion {
        return '6.0'
    }

    Context 'When called with a mandatory OrganizationName' {
        It 'Should return users from the cache' {
            $result = List-UserCache -OrganizationName 'TestOrg'
            $result | Should -BeOfType 'System.Object[]'
            $result.Count | Should -Be 2
            $result[0].displayName | Should -Be 'User One'
            $result[1].displayName | Should -Be 'User Two'
        }

        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            List-UserCache -OrganizationName 'TestOrg'
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq 'https://vssps.dev.azure.com/TestOrg/_apis/graph/users' -and $Method -eq 'Get'
            }
        }

        It 'Should call Get-AzDevOpsApiVersion once' {
            List-UserCache -OrganizationName 'TestOrg'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1 -Scope It
        }
    }

    Context 'When no users are returned' {
        Mock Invoke-AzDevOpsApiRestMethod {
            return @{
                value = $null
            }
        }

        It 'Should return $null when no users are returned' {
            $result = List-UserCache -OrganizationName 'TestOrg'
            $result | Should -Be $null
        }
    }

    Context 'When ApiVersion is provided' {
        Mock Invoke-AzDevOpsApiRestMethod {
            return @{
                value = @(
                    @{ id = 3; displayName = 'User Three' }
                )
            }
        }

        It 'Should use the provided ApiVersion' {
            $result = List-UserCache -OrganizationName 'TestOrg' -ApiVersion '5.0'
            $result | Should -BeOfType 'System.Object[]'
            $result.Count | Should -Be 1
            $result[0].displayName | Should -Be 'User Three'
        }
    }
}

