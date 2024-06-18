<#
.SYNOPSIS
    Enumeration of Azure DevOps build permissions.

.DESCRIPTION
    The AzDoBuild enumeration represents the different permissions that can be assigned to a user or group for Azure DevOps builds.

    The available permissions are:
    - ViewBuilds: Permission to view builds.
    - EditBuildQuality: Permission to edit build quality.
    - RetainIndefinitely: Permission to retain builds indefinitely.
    - DeleteBuilds: Permission to delete builds.
    - ManageBuildQualities: Permission to manage build qualities.
    - DestroyBuilds: Permission to destroy builds.
    - UpdateBuildInformation: Permission to update build information.
    - QueueBuilds: Permission to queue builds.
    - ManageBuildQueue: Permission to manage build queue.
    - StopBuilds: Permission to stop builds.
    - ViewBuildDefinition: Permission to view build definitions.
    - EditBuildDefinition: Permission to edit build definitions.
    - DeleteBuildDefinition: Permission to delete build definitions.
    - OverrideBuildCheckinValidation: Permission to override build check-in validation.
    - AdministerBuildPermissions: Permission to administer build permissions.

Manages build permissions at the project-level and object-level.

Token format for project-level build permissions: PROJECT_ID
If you need to update permissions for a particular build definition ID, for example, 12, security token for that build definition looks as follows:
Token format for project-level, specific build permissions: PROJECT_ID/12
Example: xxxxxxxx-a1de-4bc8-b751-188eea17c3ba/12

ID: 33344d9c-fc72-4d6f-aba5-fa317101a7e9

.NOTES
    This enumeration is used in the AzureDevOpsDsc module to define build permissions for Azure DevOps resources.

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions
#>

enum AzDoBuild {
    ViewBuilds = 1
    EditBuildQuality = 2
    RetainIndefinitely = 4
    DeleteBuilds = 8
    ManageBuildQualities = 16
    DestroyBuilds = 32
    UpdateBuildInformation = 64
    QueueBuilds = 128
    ManageBuildQueue = 256
    StopBuilds = 512
    ViewBuildDefinition = 1024
    EditBuildDefinition = 2048
    DeleteBuildDefinition = 4096
    OverideBuildCheckinValidation = 8192
    AdministerBuildPermissions = 16384
}
