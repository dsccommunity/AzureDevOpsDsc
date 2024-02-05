

function Get-CacheItem {
    <#
    .SYNOPSIS
    Get a cache item from the cache.

    .DESCRIPTION
    Get a cache item from the cache.

    .PARAMETER Key
    The key of the cache item to get.

    .EXAMPLE
    Get-CacheItem -Key 'MyKey'

    .NOTES
    This function is private and should not be used directly.
    #>
    [CmdletBinding()]
    [OutputType([CacheItem])]
    param (
        [Parameter(Mandatory)]
        [string]
        $Key,

        [Parameter(Mandatory)]
        [ValidateSet('Project', 'Team', 'Group', 'GroupDescriptor')]
        [string]
        $Type
    )

    $cache = Get-CacheObject -CacheType $Type
    $cacheItem = $cache.Where({$_.Key -eq $Key})

    if ($null -eq $cacheItem) { return $null }

    return $cacheItem.Value

}
