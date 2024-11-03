<#
    .DESCRIPTION
        This example shows how to add Project Services
#>

New-AzDoAuthenticationProvider -OrganizationName 'test-organization' -PersonalAccessToken 'my-pat'

Configuration Example
{

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    Node localhost {
        AzDoProjectServices 'AddProjectServices' {
            Ensure             = 'Present'
            ProjectName        = 'SampleProject'
            GitRepositories    = 'Enabled'
            WorkBoards         = 'Disabled'
            BuildPipelines     = 'Disabled'
            TestPlans          = 'Disabled'
            AzureArtifact      = 'Disabled'
        }
    }
}
