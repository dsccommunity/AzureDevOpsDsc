<#
.SYNOPSIS
    Enumeration for Azure DevOps meta task permissions.

.DESCRIPTION
    The AzDoMetaTask enumeration defines the different permissions that can be assigned to a meta task in Azure DevOps.

Manages task group permissions to edit and delete task groups, and administer task group permissions. To manage through the web portal, see Pipeline permissions and security roles, Task group permissions.

Token format for project-level permissions: PROJECT_ID
Token format for metaTask-level permissions: PROJECT_ID/METATASK_ID

If MetaTask has parentTaskId then the Security token looks as follows:
Token Format: PROJECT_ID/PARENT_TASK_ID/METATASK_ID

ID: f6a4de49-dbe2-4704-86dc-f8ec1a294436

.NOTES
    Author: Your Name
    Date: Today's Date

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions

#>

Enum AzDoMetaTask {
    Administer = 1
    Edit = 2
    Delete = 4
}
