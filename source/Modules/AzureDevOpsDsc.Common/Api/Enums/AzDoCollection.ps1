<#
.SYNOPSIS
    Enumeration of Azure DevOps collection permissions.

.DESCRIPTION
    The AzDoCollection enum represents the different permissions that can be assigned to a collection in Azure DevOps.

Manages permissions at the organization or collection-level.

ID: 3e65f728-f8bc-4ecd-8764-7e378b19bfa7

.NOTES
    For more information, refer to the official Microsoft documentation:
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#organization-level-namespaces-and-permissions

#>

enum AzDoCollection {
    GenericRead = 1
    GenericWrite = 2
    CreateProjects = 4
    TriggerEvent = 8
    ManageTemplate = 16
    DiagnosticTrace = 32
    SynchronizeRead = 64
    ManageTestControllers = 128
    DeleteField = 256
    ManageEnterprisePolicies = 512
}
