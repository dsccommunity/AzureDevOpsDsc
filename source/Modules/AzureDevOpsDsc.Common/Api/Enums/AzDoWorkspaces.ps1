<#
.SYNOPSIS
    Enumeration of Azure DevOps workspaces permissions.

.DESCRIPTION
    This enumeration defines the different permissions that can be assigned to Azure DevOps workspaces.

Manages permissions for administering shelved changes, workspaces, and the ability to create a workspace at the organization or collection level. The Workspaces namespace applies to the TFVC repository.

Root token format: /
Token format for a specific workspace: /{workspace_name};{owner_id}

ID: 93bafc04-9075-403a-9367-b7164eac6b5c

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#organization-level-namespaces-and-permissions

#>

Enum AzDoWorkspaces {
     Read = 1
     Use = 2
     Checkin = 4
     Administer = 8
}
