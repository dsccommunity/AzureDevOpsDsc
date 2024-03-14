<#
.SYNOPSIS
Imports a cache object for Azure DevOps API.

.DESCRIPTION
The Import-CacheObject function is used to import a cache object for Azure DevOps API. It checks if the cache file exists and imports its content if found. The cache object is then stored in a global variable.

.PARAMETER CacheType
Specifies the type of cache object to import. Valid values are 'Project', 'Team', 'Group', and 'SecurityDescriptor'.

.PARAMETER CacheRootPath
Specifies the root path where the cache directory is located. By default, it uses the current script's root path.

.EXAMPLE
Import-CacheObject -CacheType Project -CacheRootPath "C:\Cache"

This example imports the cache object for the 'Project' type from the cache directory located at "C:\Cache".

.INPUTS
None.

.OUTPUTS
None.

.NOTES
#>

function Import-CacheObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]$CacheType,

        [Parameter()]
        [String]$CacheRootPath = $PSScriptRoot
    )

    # Write initial verbose message
    Write-Verbose "[Import-CacheObject] Starting to import cache object for type: $CacheType"
    Write-Verbose "[Import-CacheObject] Cache root path: $CacheRootPath"

    try {

        # Determine cache directory path
        $cachePath = Join-Path -Path $CacheRootPath -ChildPath 'Cache'

        # Determine cache file path
        $cacheFile = Join-Path -Path $cachePath -ChildPath "$CacheType.clixml"

        # Check if cache file exists
        if (-not (Test-Path -Path $cacheFile)) {
            Write-Error "[Import-CacheObject] Cache file not found at path: $cacheFile"
        }

        Write-Verbose "[Import-CacheObject] Importing content from cache file at path: $cacheFile"

        $Content = Import-Clixml -Path $cacheFile
        Set-Variable -Name "AzDo$CacheType" -Value $Content -Scope Global -Force
        Write-Verbose "[Import-CacheObject] Successfully imported cache object for type: $CacheType"

        # Convert the imported cache object to a list of CacheItem objects
        $newCache = [System.Collections.Generic.List[CacheItem]]
        $cacheValue = Get-Variable -Name "AzDo$CacheType" -ValueOnly
        $newCache = $cacheValue | ForEach-Object {

            # If the key is empty, skip the item
            if ([string]::IsNullOrEmpty($_.Key)) { return }

            # Create a new CacheItem object and add it to the list
            $newCache.Add([CacheItem]::New($_.Key, $_.Value))

        }

        # Update the new cache object
        Set-Variable -Name "AzDo$CacheType" -Value $newCache -Scope Global -Force
        Write-Verbose "[Import-CacheObject] Cache object imported successfully for '$CacheType'."

    } catch {

        Write-Error "[Import-CacheObject] Failed to import cache for Azure DevOps API: $_"
        throw

    }
}
