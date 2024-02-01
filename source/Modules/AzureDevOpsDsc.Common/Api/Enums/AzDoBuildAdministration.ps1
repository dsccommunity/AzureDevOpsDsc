<#
.SYNOPSIS
    Enumeration of Azure DevOps build administration permissions.

.DESCRIPTION
    This enumeration defines the different permissions related to Azure DevOps build administration.

    The values of this enumeration are based on the permissions defined in Azure DevOps. For more information, refer to the official documentation.

Manages access to view, manage, use, or administer permissions for build resources.

ID: 302acaca-b667-436d-a946-87133492041c

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#organization-level-namespaces-and-permissions

#>
enum AzDoBuildAdministration {
    ViewBuildResources = 1
    ManageBuildResources = 2
    UseBuildResources = 4
    AdministerBuildResourcePermissions = 8
    ManagePipelinePolicies = 16
}
