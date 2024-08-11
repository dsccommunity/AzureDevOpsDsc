Describe "xAzDoProjectGroup Integration Tests" {

    BeforeAll {

        #
        # Perform setup tasks here

        $PROJECTNAME = 'TESTPROJECT_PROJECTGROUP'
        $GROUPNAME = 'TESTPROJECTGROUP'

        # Define common parameters
        $parameters = @{
            Name = 'xAzDoProjectGroup'
            ModuleName = 'AzureDevOpsDsc'
        }

        #
        # Create a new project

        New-Project $PROJECTNAME

    }

    # This context is used to test if a project group exists.
    Context "Testing if a Project Group Exists" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Test', which means we are testing the presence of a resource.
            $parameters.Method = 'Test'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTPROJECT_PROJECTGROUP'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
                GroupName = $GROUPNAME
            }

        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return True" {
            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Present',
            # indicating that the project 'TESTPROJECT_PROJECTGROUP' exists.
            $result.InDesiredState | Should -BeTrue
        } -because "The project group exists"

    }

    # This context is used to test the creation of a new project group.
    Context "Creating a new Project Group" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTPROJECT_PROJECTGROUP' and a group name 'TESTPROJECTGROUP'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
                GroupName = $GROUPNAME
                GroupDescription = 'This is a test project group.'
            }

        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return True" {
            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Present',
            # indicating that the project group 'TESTPROJECTGROUP' was created.
            $result.InDesiredState | Should -BeTrue
        } -because "The project group was created"

    }

    # This context is used to test the removal of a project group.
    Context "Removing a Project Group" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are removing a resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTPROJECT_PROJECTGROUP' and a group name 'TESTPROJECTGROUP'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
                GroupName = $GROUPNAME
                Ensure = 'Absent'
            }

        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return True" {
            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Absent',
            # indicating that the project group 'TESTPROJECTGROUP' was removed.
            $result.InDesiredState | Should -BeTrue
        } -because "The project group was removed"

    }

}
