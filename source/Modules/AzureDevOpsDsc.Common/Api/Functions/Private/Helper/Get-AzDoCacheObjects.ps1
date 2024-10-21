<#
.SYNOPSIS
Retrieves a list of Azure DevOps cache object types.

.DESCRIPTION
The Get-AzDoCacheObjects function returns an array of strings representing different types of cache objects used in Azure DevOps.

.OUTPUTS
String[]
An array of strings representing the cache object types.

.EXAMPLE
PS> Get-AzDoCacheObjects
This command retrieves the list of Azure DevOps cache object types.

#>
function Get-AzDoCacheObjects
{
    return @(
        'Project',
        'Team',
        'Group',
        'SecurityDescriptor',
        'LiveGroups',
        'LiveProjects',
        'LiveUsers',
        'LiveGroupMembers',
        'LiveRepositories',
        'LiveServicePrinciples',
        'LiveACLList',
        'LiveProcesses',
        'SecurityNamespaces'
    )

}
