Configuration OrganizationGroups {

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName AzureDevOpsDsc

    Node localhost {

        AzDoOrganizationGroup CreateTestGroup {

            GroupName = "TestGroup"
            GroupDisplayName = "Test Group"
            GroupDescription = "I am a test group."

        }

        AzDoOrganizationGroupMembers CreateTestGroup-Members {

            DependsOn = '[AzDoOrganizationGroup]CreateTestGroup'
            Members = @( 'michael.zantta@dfr.com.au' )

        }


    }

}
