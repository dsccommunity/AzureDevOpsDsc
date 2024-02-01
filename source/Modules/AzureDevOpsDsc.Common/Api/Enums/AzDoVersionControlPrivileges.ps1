<#
.SYNOPSIS
Enum representing version control privileges in Azure DevOps.

.DESCRIPTION
This enum defines the different version control privileges available in Azure DevOps. These privileges determine the level of access and permissions a user has for version control operations.

Manages permissions for Team Foundation Version Control (TFVC) repository.

ID: 66312704-deb5-43f9-b51c-ab4ff5e351c3

.LINK
https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#organization-level-namespaces-and-permissions

#>

Enum AzDoVersionControlPrivileges {
    CreateWorkspace = 1
    AdminWorkspaces = 2
    AdminShelvesets = 4
    AdminConnections = 8
    AdminConfiguration = 16
}
