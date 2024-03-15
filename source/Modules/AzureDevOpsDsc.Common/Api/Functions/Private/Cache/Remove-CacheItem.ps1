<#
.SYNOPSIS
Removes an item from the Azure DevOps cache.

.DESCRIPTION
The Remove-CacheItem function is used to remove an item from the Azure DevOps cache. It takes a key and a type as parameters. The key is the identifier of the item to be removed, and the type specifies the type of cache (Project, Team, Group, or SecurityDescriptor) from which the item should be removed.

.PARAMETER Key
The key of the item to be removed from the cache.

.PARAMETER Type
The type of cache from which the item should be removed. Valid values are 'Project', 'Team', 'Group', and 'SecurityDescriptor'.

.EXAMPLE
Remove-CacheItem -Key "myKey" -Type "Project"
Removes the item with the key "myKey" from the Project cache.

.EXAMPLE
Remove-CacheItem -Key "anotherKey" -Type "Group"
Removes the item with the key "anotherKey" from the Group cache.
#>

Function Remove-CacheItem {
    param (
        [Parameter(Mandatory)]
        [string]
        $Key,

        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]
        $Type
    )

    Write-Verbose "[Remove-CacheItem] Retrieving the current cache."
    #$cache = Get-AzDevOpsCache -CacheType $Type
    $cache = Get-CacheObject -CacheType $Type

    0 .. $cache.Length | Where-Object { $cache[$_] -eq $Key } | ForEach-Object { $cache.RemoveAt($_) }

    # Update the memory cache
    Set-Variable -Name "AzDo$Type" -Value $cache -Scope Global

}
