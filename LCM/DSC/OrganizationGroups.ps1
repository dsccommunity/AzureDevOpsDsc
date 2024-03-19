Configuration OrganizationGroups {
    param()

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName AzureDevOpsDsc -ModuleVersion 1.0.0

    Node localhost {

        xAzDoOrganizationGroup CreateTestGroup {

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
