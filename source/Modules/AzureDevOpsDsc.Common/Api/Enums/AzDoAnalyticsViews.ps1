<#
.SYNOPSIS
    Enumeration of Azure DevOps Analytics views and their corresponding permissions.

.DESCRIPTION
    The AzDoAnalyticsViews enumeration defines the different views available in Azure DevOps Analytics
    and their corresponding permissions.

    The values of the enumeration represent the permissions that can be assigned to each view:
    - Read: Permission to read the view.
    - Edit: Permission to edit the view.
    - Delete: Permission to delete the view.
    - Execute: Permission to execute the view.
    - ManagePermissions: Permission to manage permissions for the view.

    For more information, refer to the official documentation:
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions

Manages Analytics views permissions at the project-level and object-level to read, edit, delete, and generate reports. You can manage these permissions for each Analytics view from the user interface.

Token format for project level permissions: $/Shared/PROJECT_ID
Example: $/Shared/xxxxxxxx-a1de-4bc8-b751-188eea17c3ba

ID: d34d3680-dfe5-4cc6-a949-7d9c68f73cba

.NOTES
    Author: [Your Name]
    Date: [Current Date]

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions
#>

Enum AzDoAnalyticsViews {
    Read = 1
    Edit = 2
    Delete = 4
    Execute = 8
    ManagePermissions = 16
}
