Describe "AzDoGroupPermission intergration tests" -skip {

    BeforeAll {

        # Perform setup tasks here
        $PROJECTNAME = 'TESTPROJECT_GIT_GROUP_PERMISSION'
        $GroupName = 'TESTGROUP'

        $parameters = @{
            Name = 'AzDoGroupPermission'
            ModuleName = 'AzureDevOpsDsc'
            property = @{
                GroupName = "[$PROJECTNAME]\$GroupName"
                isInherited = $false
                Permissions = @(
                    @{
                        Identity = "this"
                        Permission = @{
                            Read = 'Allow'
                            Write = 'Allow'
                        }
                    }
                    @{
                        Identity = "[$PROJECTNAME]\Group1"
                        Permission = @{
                            Read = 'Allow'
                            Write = 'Allow'
                        }
                    }
                )
            }
        }

        #
        # Create a new project

        New-Project $PROJECTNAME

        #
        # Create a new group

        New-Group $GroupName -ProjectName $PROJECTNAME
        New-Group 'Group1' -ProjectName $PROJECTNAME

    }

    Context "Testing if the permissions exist" {

        BeforeAll {
            $parameters.Method = 'Test'
        }

        It "Should return False" {
            $result = Invoke-DscResource @parameters
            $result.InDesiredState | Should -BeFalse
        }

    }

    # Create a new group
    Context "Setting new Group Permissions" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return True" {

            # Set the Method to 'Test' to verify that the git repository exists.
            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Present',
            # indicating that the git repository 'TESTREPOSITORY' exists.
            $result.InDesiredState | Should -BeTrue
        }

    }

    # Change the permissions
    Context "Changing Group Permissions" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Set the permissions to a new value
            $parameters.property.Permissions = @(
                @{
                    Identity = "[$PROJECTNAME]\Group1"
                    Permission = @{
                        Read = 'Allow'
                        Write = 'Deny'
                    }
                }
            )
        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return True" {

            # Set the Method to 'Test' to verify that the git repository exists.
            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Present',
            # indicating that the git repository 'TESTREPOSITORY' exists.
            $result.InDesiredState | Should -BeTrue
        }

    }

}
