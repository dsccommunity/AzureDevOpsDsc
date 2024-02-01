
<#
.SYNOPSIS
    Enumeration of permissions for Azure DevOps iterations.

.DESCRIPTION
    The AzDoIteration enumeration defines the permissions available for Azure DevOps iterations.

    The available permissions are:
    - GenericRead: Read permission.
    - GenericWrite: Write permission.
    - CreateChildren: Permission to create child iterations.
    - Delete: Permission to delete iterations.

Manages iteration path object-level permissions to create, edit, and delete child nodes and view child node permissions. To manage through the web portal, see Set permissions and access for work tracking, Create child nodes.
Token format: 'vstfs:///Classification/Node/Iteration_Identifier/'
Suppose, you have the following iterations configured for your team.
– ProjectIteration1
  TeamIteration1
     – TeamIteration1ChildIteration1
     – TeamIteration1ChildIteration2
     – TeamIteration1ChildIteration3
  TeamIteration2
     – TeamIteration2ChildIteration1
     – TeamIteration2ChildIteration2

To update permissions for ProjectIteration1\TeamIteration1\TeamIteration1ChildIteration1, the security token looks as follows:
vstfs:///Classification/Node/ProjectIteration1_Identifier:vstfs:///Classification/Node/TeamIteration1_Identifier:vstfs:///Classification/Node/TeamIteration1ChildIteration1_Identifier

ID: bf7bfa03-b2b7-47db-8113-fa2e002cc5b1

.LINK
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions

#>

Enum AzDoIteration {
    GenericRead = 1
    GenericWrite = 2
    CreateChildren = 4
    Delete = 8
}
