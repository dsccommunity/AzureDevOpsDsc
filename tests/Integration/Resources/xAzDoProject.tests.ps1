Describe "xAzDoProject Integration Tests" {

    BeforeAll {

        # Perform setup tasks here

        # Define common parameters
        $parameters = @{
            Name = 'xAzDoProject'
            ModuleName = 'AzureDevOpsDsc'
        }

        $PROJECTNAME = 'TESTPROJECT'

    }

    # This context is used to test if a project exists.
    Context "Testing if a Project Exists" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Test', which means we are testing the presence of a resource.
            $parameters.Method = 'Test'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTPROJECT'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
            }
        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return False" {
            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Absent',
            # indicating that the project 'TESTPROJECT' does not exist.
            $result.InDesiredState | Should -BeFalse
        } -because "The project does not exist"

    }

    # This context is used to test the creation of a new project.
    Context "Creating a new Project" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name using the variable '$PROJECTNAME'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
            }
        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should be successful" {
            # Set the 'Method' to 'Test' to verify that the project was successfully created.
            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Present',
            # indicating that the project specified by '$PROJECTNAME' was successfully created.
            $result.InDesiredState | Should -BeTrue
        } -because "The project was successfully created"

    }

    # This context is used to test the deletion of an existing project.
    Context "Deleting an existing Project" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are deleting an existing resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name using the variable '$PROJECTNAME'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
                Ensure = 'Absent'
            }
        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should be successful" {
            # Set the 'Method' to 'Test' to verify that the project was successfully deleted.
            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Absent',
            # indicating that the project specified by '$PROJECTNAME' was successfully deleted.
            $result.InDesiredState | Should -BeFalse
        } -because "The project was successfully deleted"

    }

}
