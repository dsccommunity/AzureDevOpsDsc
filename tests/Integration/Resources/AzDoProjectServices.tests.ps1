Describe "AzDoProjectServices Integration Tests" {

    BeforeAll {

        Mock Write-Verbose { param($Message) }

        #
        # Perform setup tasks here

        $PROJECTNAME = 'TEST_PROJECTSERVICES'
        $GROUPNAME = 'TESTPROJECTGROUP'

        # Define common parameters
        $parameters = @{
            Name = 'AzDoProjectServices'
            ModuleName = 'AzureDevOpsDsc'
        }

        #
        # Create a new project

        New-Project $PROJECTNAME

    }

    # This context is used to test if a project services exist.
    Context "Testing if a Project Services Exists" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Test', which means we are testing the presence of a resource.
            $parameters.Method = 'Test'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TEST_PROJECTSERVICES'.
            $properties = @{
                ProjectName = $PROJECTNAME
                GitRepositories = 'Enabled'
                WorkBoards = 'Enabled'
                BuildPipelines = 'Enabled'
                TestPlans = 'Enabled'
                AzureArtifact = 'Enabled'
            }

            $parameters.property = $properties
        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return True" {
            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Present',
            # indicating that the project 'TEST_PROJECTSERVICES' exists.
            $result.InDesiredState | Should -BeTrue
        }
    }

    # This context is used to test the creation of a new project services.
    Context "Creating a new Project Services" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name using the variable '$PROJECTNAME'.
            $properties = @{
                ProjectName = $PROJECTNAME
                GitRepositories = 'Enabled'
                WorkBoards = 'Enabled'
                BuildPipelines = 'Disabled'
                TestPlans = 'Disabled'
                AzureArtifact = 'Enabled'
            }

            $parameters.property = $properties
        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }
    }

    # This context is used to test the deletion of an existing project services.
    Context "Disabling existing Project Services" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are deleting an existing resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name using the variable '$PROJECTNAME'.
            $properties = @{
                ProjectName = $PROJECTNAME
                GitRepositories = 'Disabled'
                WorkBoards = 'Disabled'
                BuildPipelines = 'Disabled'
                TestPlans = 'Disabled'
                AzureArtifact = 'Disabled'
            }

            $parameters.property = $properties
        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should be within desired state" {

            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that the 'Ensure' property in the result is 'Present',
            # indicating that the project services were successfully disabled.
            $result.InDesiredState | Should -BeTrue
        }

    }

}

