# Import the module containing the AzDoGroupPermission class
# Describe block for AzDoGroupPermission tests
Describe 'AzDoGroupPermission Tests' {

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
            $currentState.Permissions | Should -Be @(
                @{ Permission = 'Read'; Allow = $true }
            )
        }
    }
}
