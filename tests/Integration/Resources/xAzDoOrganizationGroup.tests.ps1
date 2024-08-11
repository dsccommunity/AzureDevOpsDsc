Describe "xAzDoOrganizationGroup Integration Tests" {

    BeforeAll {

        # Perform setup tasks here

        # Define common parameters
        $parameters = @{
            Name = 'xAzDoOrganizationGroup'
            ModuleName = 'AzureDevOpsDsc'
        }

        $PROJECTNAME = 'TESTORGANIZATIONGROUP'

        #
        # Create a new project

        New-Project $PROJECTNAME

    }

    # This context is used to test if a organization group exists.
    Context "Testing if a Organization Group Exists" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Test', which means we are testing the presence of a resource.
            $parameters.Method = 'Test'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTORGANIZATIONGROUP'.
            $parameters.properties = @{
                OrganizationName = $PROJECTNAME
                GroupName = 'TESTORGANIZATIONGROUP'
                GroupDescription = 'This is a test organization group.'
            }

        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return False" {

            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that it is not in the desired state
            $result.InDesiredState | Should -BeFalse
        }
    }

    # This context is used to test if a organization group can be created.
    Context "Testing if a Organization Group Can Be Created" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTORGANIZATIONGROUP'.
            $parameters.properties = @{
                OrganizationName = $PROJECTNAME
                GroupName = 'TESTORGANIZATIONGROUP'
                GroupDescription = 'This is a test organization group.'
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

            # Verify that it is in the desired state
            $result.InDesiredState | Should -BeTrue
        }
    }

    # This context is used to test if a organization group can be removed.
    Context "Testing if a Organization Group Can Be Removed" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTORGANIZATIONGROUP'.
            $parameters.properties = @{
                OrganizationName = $PROJECTNAME
                GroupName = 'TESTORGANIZATIONGROUP'
                GroupDescription = 'This is a test organization group.'
            }

            # Invoke the DSC resource to create a new organization group.
            $null = Invoke-DscResource @parameters

            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are removing a resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTORGANIZATIONGROUP'.
            $parameters.properties = @{
                OrganizationName = $PROJECTNAME
                GroupName = 'TESTORGANIZATIONGROUP'
                GroupDescription = 'This is a test organization group.'
            }

        }

        It "Should not throw any exceptions" {
            # Test that invoking the DSC resource with the specified parameters does not throw any exceptions.
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return False" {

            $parameters.Method = 'Test'

            # Invoke the DSC resource with the specified parameters and store the result.
            $result = Invoke-DscResource @parameters

            # Verify that it is not in the desired state
            $result.InDesiredState | Should -BeFalse
        }
    }

}
