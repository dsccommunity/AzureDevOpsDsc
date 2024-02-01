# Source of the enum: https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#project-level-namespaces-and-permissions

<#
.SYNOPSIS
Enum representing the permissions for Azure DevOps tagging.

.DESCRIPTION
The AzDoTagging enum represents the permissions available for Azure DevOps tagging. It is used to define the level of access granted for various tagging operations.

Manages permissions to create, delete, enumerate, and use work item tags. You can manage the Create tag definition permission through the Project settings, Permissions administrative interface.

Token format for project-level permissions: /PROJECT_ID
Example: /xxxxxxxx-a1de-4bc8-b751-188eea17c3ba

ID: bb50f182-8e5e-40b8-bc21-e8752a1e7ae2

.PARAMETER Enumerate
Permission to enumerate tags.

.PARAMETER Create
Permission to create tags.

.PARAMETER Update
Permission to update tags.

.PARAMETER Delete
Permission to delete tags.
#>

Enum AzDoTaggingPermission {
    Enumerate = 1
    Create = 2
    Update = 4
    Delete = 8
}
