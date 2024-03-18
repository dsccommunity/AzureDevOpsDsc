Configuration OrganizationGroups {

    Import-DscResource -ModuleName AzureDevOpsDsc

    Node localhost {

        AzDoOrganizationGroup CreateTestGroup {

            GroupName = "TestGroup"
            GroupDisplayName = "Test Group"
            GroupDescription = "I am a test group."

        }

    }

}
