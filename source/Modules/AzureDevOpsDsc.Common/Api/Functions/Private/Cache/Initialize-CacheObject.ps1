<#
.SYNOPSIS
    Initializes the cache object for Azure DevOps API.

.DESCRIPTION
    This function is used to initialize the cache object for Azure DevOps API. It checks if the cache file exists and imports the cache object if it does. If the cache file does not exist, it creates a new cache object.

.PARAMETER CacheType
    Specifies the type of cache to initialize. Valid values are 'Project', 'Team', 'Group', and 'SecurityDescriptor'.

.EXAMPLE
    Initialize-CacheObject -CacheType Project
    Initializes the cache object for the 'Project' cache type.

.NOTES
#>
Function Initialize-CacheObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]$CacheType

    )

    try {

        $CacheDirectoryPath = Join-Path -Path $ModuleRoot -ChildPath "Cache"

        $cacheFilePath = Join-Path -Path $ModuleRoot -ChildPath "Cache\$CacheType.clixml"
        Write-Verbose "[Initialize-CacheObject] Cache file path: $cacheFilePath"

        # If the cache group is LiveGroups or LiveProjects, set the cache file path to the temporary directory
        if (($CacheType -eq 'LiveGroups') -or ($CacheType -eq 'LiveProjects')) {

            # Flush the cache if it is a live cache
            if (Test-Path -LiteralPath $cacheFilePath -ErrorAction SilentlyContinue) {
                Write-Verbose "[Initialize-CacheObject] Cache file found. Removing cache file for '$CacheType'."
                Remove-Item -LiteralPath $cacheFilePath -Force
            }

        }

        # Test if the Cache File exists. If it exists, import the cache object
        if (Test-Path -Path $cacheFilePath) {

            # If the cache file exists, import the cache object
            Write-Verbose "[Initialize-CacheObject] Cache file found. Importing cache object for '$CacheType'."
            Import-CacheObject -CacheType $CacheType -CacheRootPath $CacheDirectoryPath

        } else {

            # If the cache file does not exist, create a new cache object
            Write-Verbose "[Initialize-CacheObject] Cache file not found. Creating new cache object for '$CacheType'."
            Set-CacheObject -CacheType $CacheType -Content ([System.Collections.Generic.List[CacheItem]]::New()) -CacheRootPath $CacheDirectoryPath

        }

    } catch {
        Write-Verbose "An error occurred: $_"
        throw "[Initialize-CacheObject] Failed to import cache for Azure DevOps API: $_"
    }

}
