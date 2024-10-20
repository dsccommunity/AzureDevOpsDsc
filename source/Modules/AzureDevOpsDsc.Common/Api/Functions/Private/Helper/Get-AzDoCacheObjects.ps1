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
