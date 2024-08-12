Describe "xAzDoGitRepository Integration Tests" {

    BeforeAll {

        # Perform setup tasks here
        $PROJECTNAME = 'TESTPROJECT_GITREPOSITORY'

        # Define common parameters
        $parameters = @{
            Name = 'xAzDoGitRepository'
            ModuleName = 'AzureDevOpsDsc'
        }

        #
        # Create a new project

        New-Project $PROJECTNAME

    }

    # This context is used to test if a git repository exists.
    Context "Testing if a Git Repository Exists" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Test', which means we are testing the presence of a resource.
            $parameters.Method = 'Test'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTPROJECT'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
                RepositoryName = 'TESTREPOSITORY'
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
            # indicating that the git repository 'TESTREPOSITORY' does not exist.
            $result.InDesiredState | Should -BeFalse
        }

    }

    # This context is used to test the creation of a new git repository.
    Context "Creating a new Git Repository Permissions" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name using the variable '$PROJECTNAME'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
                RepositoryName = 'TESTREPOSITORY'
                Ensure = 'Present'
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
            # indicating that the git repository 'TESTREPOSITORY' exists.
            $result.InDesiredState | Should -BeTrue
        }

    }

    # This context is used to test the deletion of a git repository.
    Context "Deleting an Existing Git Repository" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are deleting an existing resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name using the variable '$PROJECTNAME'.
            $parameters.properties = @{
                ProjectName = $PROJECTNAME
                RepositoryName = 'TESTREPOSITORY'
                Ensure = 'Absent'
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

            # Verify that the 'Ensure' property in the result is 'Absent',
            # indicating that the git repository 'TESTREPOSITORY' was deleted.
            $result.InDesiredState | Should -BeTrue
        }

    }

}
