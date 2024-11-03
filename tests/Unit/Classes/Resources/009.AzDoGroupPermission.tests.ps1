
Describe 'AzDoGroupPermission Tests' {

    BeforeAll {
        $ENV:AZDODSC_CACHE_DIRECTORY = 'mocked_cache_directory'

        Mock -CommandName Import-Module
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Import-Clixml -MockWith {
            return @{
                OrganizationName = 'mock-org'
                Token = @{
                    tokenType = 'ManagedIdentity'
                    access_token = 'mock_access_token'
                }

            }
        }
        Mock -CommandName New-AzDoAuthenticationProvider
        Mock -CommandName Get-AzDoCacheObjects -MockWith {
            return @('mock-cache-type')
        }
        Mock -CommandName Initialize-CacheObject

    }
    AfterAll {

        $ENV:AZDODSC_CACHE_DIRECTORY = $null

    }

    # Test case to check if the class can be instantiated
    Context 'Instantiation' {
        It 'Should create an instance of the AzDoGroupPermission class' {
            $groupPermission = [AzDoGroupPermission]::new()
            $groupPermission | Should -Not -BeNullOrEmpty
            $groupPermission | Should -BeOfType 'AzDoGroupPermission'
        }
    }

    # Test case to check default values
    Context 'Default Values' {
        It 'Should have default value for isInherited as $true' {
            $groupPermission = [AzDoGroupPermission]::new()
            $groupPermission.isInherited | Should -Be $true
        }
    }

    # Test case to check property assignments
    Context 'Property Assignments' {
        It 'Should allow setting and getting GroupName property' {
            $groupPermission = [AzDoGroupPermission]::new()
            $groupPermission.GroupName = 'TestGroup'
            $groupPermission.GroupName | Should -Be 'TestGroup'
        }

        It 'Should allow setting and getting Permissions property' {
            $groupPermission = [AzDoGroupPermission]::new()
            $permissions = @(
                @{ Permission = 'Read'; Allow = $true },
                @{ Permission = 'Write'; Allow = $false }
            )
            $groupPermission.Permissions = $permissions
            $groupPermission.Permissions | Should -Be $permissions
        }
    }

    # Test case for Get method
    Context 'Get Method' {

        BeforeAll {
            Mock -CommandName Get-AzDoGroupPermission {

                $properties = @{
                    Ensure = [Ensure]::Absent
                    propertiesChanged = @()
                    GroupName = 'TestGroup'
                    Permissions = @{
                        'mock-permission' = @{
                            Permission = 'Read'
                            Allow = $true
                        }
                    }
                    isInherited = $false
                    status = $null
                    reason = $null
                }

                return $properties

            }

        }

        It 'Should return current state properties' {

            $groupPermission = [AzDoGroupPermission]::new()
            $groupPermission.GroupName = 'TestGroup'
            $groupPermission.isInherited = $false
            $groupPermission.Permissions = @(
                @{ Permission = 'Read'; Allow = $true }
            )

            $currentState = $groupPermission.Get()

            $currentState.GroupName | Should -Be 'TestGroup'
            $currentState.isInherited | Should -Be $false
            $currentState.Permissions | Should -Not -BeNullOrEmpty

            Assert-MockCalled Get-AzDoGroupPermission -Exactly 1

        }
    }

    Context 'Test Method' {

        BeforeAll {

        }

        It 'Should return $true when calling the test method - when the current state is unchanged' {

            Mock -CommandName Get-AzDoGroupPermission {

                $properties = @{
                    Ensure = [Ensure]::Present
                    propertiesChanged = @()
                    GroupName = 'TestGroup'
                    Permissions = @{
                        'mock-permission' = @{
                            Permission = 'Read'
                            Allow = $true
                        }
                    }
                    isInherited = $false
                    status = [DSCGetSummaryState]::Unchanged
                    reason = $null
                }

                return $properties

            }

            $groupPermission = [AzDoGroupPermission]::new()
            $groupPermission.GroupName = 'TestGroup'
            $groupPermission.Permissions = @(
                @{ Permission = 'Read'; Allow = $true }
            )

            $groupPermission.Test() | Should -Be $true


        }

        It 'Should return $false when calling the test method - when the current state is changed' {

            Mock -CommandName Get-AzDoGroupPermission {

                $properties = @{
                    Ensure = [Ensure]::Absent
                    propertiesChanged = @()
                    GroupName = 'TestGroup'
                    Permissions = @{
                        'mock-permission' = @{
                            Permission = 'Read'
                            Allow = $true
                        }
                    }
                    isInherited = $false
                    status = [DSCGetSummaryState]::Missing
                    reason = $null
                }

                return $properties

            }

            $groupPermission = [AzDoGroupPermission]::new()
            $groupPermission.GroupName = 'DifferentGroup'
            $groupPermission.Permissions = @(
                @{ Permission = 'Read'; Allow = $true }
            )

            $groupPermission.Test() | Should -Be $false

        }

        It 'Should return $false when calling the test method - when the status is null' {

            Mock -CommandName Get-AzDoGroupPermission {

                $properties = @{
                    Ensure = [Ensure]::Absent
                    propertiesChanged = @()
                    GroupName = 'TestGroup'
                    Permissions = @{
                        'mock-permission' = @{
                            Permission = 'Read'
                            Allow = $true
                        }
                    }
                    isInherited = $false
                    status = $null
                    reason = $null
                }

                return $properties

            }

            Mock -CommandName New-InvalidOperationException {
                throw 'Invalid Operation Exception'
            } -ParameterFilter {
                $Message -like "*Could not obtain a valid 'LookupResult.Status' value within*"
            }

            $groupPermission = [AzDoGroupPermission]::new()
            $groupPermission.GroupName = 'TestGroup'
            $groupPermission.Permissions = @(
                @{ Permission = 'Read'; Allow = $true }
            )

            { $groupPermission.Test() } | Should -Not -Throw
            $groupPermission.Test() | Should -Be $false
            Assert-MockCalled New-InvalidOperationException -Times 1

        }


    }

}
