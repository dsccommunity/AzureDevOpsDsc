Function Add-CacheItem {
    <#
    .SYNOPSIS
    Add a cache item to the cache.

    .DESCRIPTION
    Adds a cache item to the cache with a specified key, value, and type.

    .PARAMETER Key
    The key of the cache item to add.

    .PARAMETER Value
    The value of the cache item to add.

    .PARAMETER Type
    The type of the cache item to add. Valid values are 'Project', 'Team', 'Group', 'SecurityDescriptor'.

    .EXAMPLE
    Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project'

    .NOTES
    This function is private and should not be used directly.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Key,

        [Parameter(Mandatory)]
        [object]
        $Value,

        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]
        $Type
    )

    Write-Verbose "[Add-CacheItem] Retrieving the current cache."
    [System.Collections.Generic.List[CacheItem]]$cache = Get-CacheObject -CacheType $Type
    #Get-AzDevOpsCache -CacheType $Type

    # If the cache is empty, create a new cache
    if ($cache.count -eq 0) {
        Write-Verbose "[Add-CacheItem] Cache is empty. Creating new cache."
        $cache = [System.Collections.Generic.List[CacheItem]]::New()
    }

    Write-Verbose "[Add-CacheItem] Creating new cache item with key: '$Key'."
    $cacheItem = [CacheItem]::New($Key, $Value)

    Write-Verbose "[Add-CacheItem] Checking if the cache already contains the key: '$Key'."
    $existingItem = $cache | Where-Object { $_.Key -eq $Key }

    if ($existingItem) {
        Write-Warning "[Add-CacheItem] A cache item with the key '$Key' already exists. Flushing key from the cache."
        Remove-CacheItem -Key $Key -Type $Type
        # Refresh the cache
        [System.Collections.Generic.List[CacheItem]]$cache = Get-CacheObject -CacheType $Type
    }

    Write-Verbose "[Add-CacheItem] Adding new cache item with key: '$Key'."
    $cache.Add($cacheItem)

    # Update the memory cache
    Set-Variable -Name "AzDo$Type" -Value $cache -Scope Global

    Write-Verbose "[Add-CacheItem] Cache item with key: '$Key' successfully added."
}
