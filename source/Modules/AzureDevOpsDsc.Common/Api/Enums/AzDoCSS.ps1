
<#
.SYNOPSIS
    Enumeration of Azure DevOps CSS (Common Structure Service) permissions.

.DESCRIPTION
    The AzDoCSS enumeration defines the permissions available in Azure DevOps CSS (Common Structure Service).
    These permissions can be used to control access to various objects and operations within Azure DevOps.

Manages area path object-level permissions to create, edit, and delete child nodes and set permissions to view or edit work items in a node. You can manage these permissions through the Set permissions and access for work tracking, Create child nodes, modify work items under an area path.

ID: 83e28ad4-2d72-4ceb-97b0-c7726d5502c3

.NOTES
    For more information, refer to the official documentation:
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions

#>
enum AzDoCSS {
    GenericRead = 1
    GenericWrite = 2
    CreateChildren = 4
    Delete = 8
    WorkItemRead = 16
    WorkItemWrite = 32
    ManageTestPlans = 64
    ManageTestSuites = 128
}
