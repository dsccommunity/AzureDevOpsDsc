<#
.SYNOPSIS
    Enumeration of permissions for Azure DevOps Release Management.

.DESCRIPTION
    This enumeration defines the different permissions available for Azure DevOps Release Management.
    Each permission is represented by a numeric value.

    The available permissions are:
    - ViewReleaseDefinition
    - EditReleaseDefinition
    - DeleteReleaseDefinition
    - ManageReleaseApprovers
    - ManageReleases
    - ViewRelease
    - CreateReleases
    - EditReleaseEnviroment
    - DeleteReleaseEnvironment
    - AdministerReleasePermissions
    - DeleteReleases
    - ManageDeployments
    - ManageReleaseSettings
    - ManageTaskHubExtension

    For more information, refer to the source link provided.

Manages release definition permissions at the project and object-level.

Token format for project-level permissions: PROJECT_ID
Example: xxxxxxxx-a1de-4bc8-b751-188eea17c3ba
If you need to update permissions for a particular release definition ID, for example, 12, security token for that release definition looks as follows:

Token format for specific release definition permissions: PROJECT_ID/12
Example: xxxxxxxx-a1de-4bc8-b751-188eea17c3ba/12
If the release definition ID lives in a folder, then the security tokens look as follows:
Token format: PROJECT_ID/{folderName}/12
For stages, tokens look like: PROJECT_ID/{folderName}/{DefinitionId}/Environment/{EnvironmentId}.

ID: c788c23e-1b46-4162-8f5e-d7585343b5de

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions
#>
enum AzReleaseManagement {
    ViewReleaseDefinition = 1
    EditReleaseDefinition = 2
    DeleteReleaseDefinition = 4
    ManageReleaseApprovers = 8
    ManageReleases = 16
    ViewRelease = 32
    CreateReleases = 64
    EditReleaseEnviroment = 128
    DeleteReleaseEnvironment = 256
    AdministerReleasePermissions = 512
    DeleteReleases = 1024
    ManageDeployments = 2048
    ManageReleaseSettings = 4096
    ManageTaskHubExtension = 8192
}
