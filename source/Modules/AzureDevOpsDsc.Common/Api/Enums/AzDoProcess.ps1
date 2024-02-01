<#
.SYNOPSIS
    Enumeration of Azure DevOps process permissions.

.DESCRIPTION
    The AzDoProcess enumeration defines the different process permissions in Azure DevOps.

    Edit - Permission to edit a process.
    Delete - Permission to delete a process.
    Create - Permission to create a process.
    AdministerProcessPermission - Permission to administer process permissions.
    ReadProcessPermissions - Permission to read process permissions.

Manages permissions to create, delete, and administer processes.
ID: 2dab47f9-bd70-49ed-9bd5-8eb051e59c02

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#organization-level-namespaces-and-permissions
#>

Enum AzDoProcess {
    Edit = 1
    Delete = 2
    Create = 4
    AdministerProcessPermission = 8
    ReadProcessPermissions = 16
}
