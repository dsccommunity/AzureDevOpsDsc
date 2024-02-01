<#
.SYNOPSIS
    Enumeration of Azure DevOps plan permissions.

.DESCRIPTION
    The AzDoPlan enumeration defines the different permissions that can be assigned to a plan in Azure DevOps.

Manages permissions for Delivery Plans to view, edit, delete, and manage delivery plans. You can manage these permissions through the web portal for each plan.

ID: bed337f8-e5f3-4fb9-80da-81e17d06e7a8

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions

#>

Enum AzDoPlan {
    View = 1
    Edit = 2
    Delete = 4
    Manage = 8
}
