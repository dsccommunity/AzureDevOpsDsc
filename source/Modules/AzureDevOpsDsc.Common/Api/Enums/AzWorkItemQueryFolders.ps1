<#
.SYNOPSIS
    Enumerates the permissions for work item query folders in Azure DevOps.

.DESCRIPTION
    The WorkItemQueryFolders enum defines the different permissions that can be assigned to work item query folders in Azure DevOps.

    - Read: Users can view the contents of the query folder.
    - Contribute: Users can modify the contents of the query folder.
    - Delete: Users can delete the query folder.
    - ManagePermissions: Users can manage permissions for the query folder.
    - FullControl: Users have full control over the query folder.
    - RecordQueryExecutionInfo: Users can record query execution information for the query folder.

Manages permissions for work item queries and query folders. To manage these through the web portal, see Set permissions and access for work tracking, Set permissions on queries or query folders.

ID: 71356614-aad7-4757-8f2c-0fb3bff6f680

.NOTES
    For more information, refer to the Azure DevOps documentation.

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions

#>

enum WorkItemQueryFolders {
    Read = 1
    Contribute = 2
    Delete = 4
    ManagePermissions = 8
    FullControl = 16
    RecordQueryExecutionInfo = 32
}
