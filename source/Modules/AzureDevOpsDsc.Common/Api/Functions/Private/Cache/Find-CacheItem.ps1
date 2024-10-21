<#
.SYNOPSIS
Searches for a CacheItem in a given list of cache items based on a filter.

.DESCRIPTION
The Find-CacheItem function searches for a CacheItem in a given list of cache items based on a filter. It returns the matching CacheItem.

.PARAMETER CacheList
The list of cache items to search in. This parameter is mandatory and accepts pipeline input.

.PARAMETER Filter
The filter to apply when searching for the CacheItem. This parameter is mandatory and accepts a script block.

.OUTPUTS
System.Management.Automation.PSObject
The matching CacheItem.

.EXAMPLE
$cacheItems = Get-CacheItems
$filteredCacheItem = $cacheItems | Find-CacheItem -Filter { $_.Name -eq 'MyCacheItem' }
$filteredCacheItem
# Returns the CacheItem with the name 'MyCacheItem' from the list of cache items.

.NOTES
Author: Your Name
Date: Today's Date
#>
Function Find-CacheItem
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [Alias('Cache')]
        [Object[]]$CacheList,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]$Filter
    )

    # Logging
    Write-Verbose "[Find-CacheItem] Searching for the CacheItem with filter '$Filter'."

    # Get the CacheItem
    $cacheItem = $null
    $cacheItem = $CacheList | Where-Object -FilterScript $Filter

    #
    # Return the CacheItem
    return $cacheItem
}
