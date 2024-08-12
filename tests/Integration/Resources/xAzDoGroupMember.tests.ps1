Describe "xAzDoGroupMember Integration Tests" {

    BeforeAll {

        # Perform setup tasks here
        $PROJECTNAME = 'TESTPROJECT_GROUPMEMBER'

        # Define common parameters
        $parameters = @{
            Name = 'xAzDoGitRepository'
            ModuleName = 'AzureDevOpsDsc'
        }

        #
        # Create a new project

        New-Project $PROJECTNAME

        #
        # Create some new groups

        'Group1', 'Group2' | ForEach-Object {
            New-Group -ProjectName $PROJECTNAME -GroupName $_
        }

    }

    # This context is used to test if a group member exists.
    Context "Testing if a Group Member Exists" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Test', which means we are testing the presence of a resource.
            $parameters.Method = 'Test'

            # Define properties for the DSC resource.
            # In this case, we specify a project name 'TESTPROJECT_GROUPMEMBER'.
            $parameters.properties = @{
                GroupName = "$PROJECTNAME\TESTGROUP"
                GroupMembers = "[$PROJECTNAME]\Group1", "[$PROJECTNAME]\Group2"
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
            # indicating that the group member 'TESTMEMBER' does not exist.
            $result.InDesiredState | Should -BeFalse
        }

    }

    # This context is used to test the creation of a new group member.
    Context "Creating a new Group Member" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are creating a new resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            $parameters.properties = @{
                GroupName = "$PROJECTNAME\TESTGROUP"
                GroupMembers = "[$PROJECTNAME]\Group1", "[$PROJECTNAME]\Group2"
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
            # indicating that the group member 'TESTMEMBER' exists.
            $result.InDesiredState | Should -BeTrue
        }

    }

    # This context is used to test the removal of a group member.
    Context "Removing a Group Member" {

        BeforeAll {
            # Set up the parameters for the DSC resource invocation.
            # 'Method' is set to 'Set', which means we are removing a resource.
            $parameters.Method = 'Set'

            # Define properties for the DSC resource.
            $parameters.properties = @{
                GroupName = "$PROJECTNAME\TESTGROUP"
                GroupMembers = @("[$PROJECTNAME]\Group1")
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
            # indicating that the group member 'TESTMEMBER' does not exist.
            $result.InDesiredState | Should -BeTrue
        }

    }

}
