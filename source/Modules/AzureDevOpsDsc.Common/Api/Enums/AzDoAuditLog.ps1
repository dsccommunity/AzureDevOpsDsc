<#
.SYNOPSIS
    Enumeration of Azure DevOps audit log permissions.

.DESCRIPTION
    The AzDoAuditLog enumeration defines the different permissions that can be assigned to audit logs in Azure DevOps.

    The available permissions are:
    - Read: Allows reading the audit logs.
    - Write: Allows writing to the audit logs.
    - ManageStreams: Allows managing the audit log streams.
    - DeleteStreams: Allows deleting the audit log streams.

Manages auditing permissions to read or write to the audit log and manage or delete audit streams.

Token format: /AllPermissions
ID: a6cc6381-a1ca-4b36-b3c1-4e65211e82b6

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#organization-level-namespaces-and-permissions

#>
enum AzDoAuditLog {
    Read = 1
    Write = 2
    ManageStreams = 4
    DeleteStreams = 8
}
