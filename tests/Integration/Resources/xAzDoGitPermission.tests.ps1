

Describe "xAzDoGitPermission Integration Tests" {

    BeforeAll {

        $parameters = @{
            Name = 'xAzDoGitPermission'
            ModuleName = 'AzureDevOpsDsc'
            property = @{
                ProjectName = $PROJECTNAME
                RepositoryName = 'TESTREPOSITORY'
                isInherited = $false
                Permissions = @(
                    @{
                        Identity = '[$PROJECTNAME]\Group1'
                        Permission = @{
                            Read = 'Allow'
                            Write = 'Allow'
                        }
                    }
                    @{
                        Identity = '[$PROJECTNAME]\Group2'
                        Permission = @{
                            Read = 'Deny'
                            Write = 'Deny'
                        }
                    }
                )
            }
        }

        # Perform setup tasks here
        $PROJECTNAME = 'TESTPROJECT_GIT_PERMISSION'

        #
        # Create a new project
        New-Project $PROJECTNAME

        #
        # Create a new repository

        New-Repository -ProjectName $PROJECTNAME -RepositoryName 'TESTREPOSITORY'

        #
        # Create some new groups

        'Group1', 'Group2' | ForEach-Object {
            New-Group -ProjectName $PROJECTNAME -GroupName $_
        }
    }

    Context "Testing if the permissions exist" {

        BeforeAll {
            $parameters.Method = 'Test'
        }

        It "Should not throw any exceptions" {
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return False" {
            $result = Invoke-DscResource @parameters
            $result.InDesiredState | Should -BeFalse
        }

    }

    Context "Creating new permissions" {

        BeforeAll {
            $parameters.Method = 'Set'
        }

        It "Should not throw any exceptions" {
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return True" {

            # Set up the parameters for the DSC resource invocation.
            $parameters.Method = 'Test'

            $result = Invoke-DscResource @parameters
            $result.InDesiredState | Should -BeTrue
        }

    }

    Context "Clearing permissions" {

        BeforeAll {
            $parameters.Method = 'Set'
            $parameters.property.Permissions = @()
        }

        It "Should not throw any exceptions" {
            { Invoke-DscResource @parameters } | Should -Not -Throw
        }

        It "Should return False" {

            # Set up the parameters for the DSC resource invocation.
            $parameters.Method = 'Test'

            $result = Invoke-DscResource @parameters
            $result.InDesiredState | Should -BeFalse
        }
    }

}
