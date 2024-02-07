<#
.SYNOPSIS
    Initializes the cache object for Azure DevOps API.

.DESCRIPTION
    This function is used to initialize the cache object for Azure DevOps API. It checks if the cache file exists and imports the cache object if it does. If the cache file does not exist, it creates a new cache object.

.PARAMETER CacheType
    Specifies the type of cache to initialize. Valid values are 'Project', 'Team', 'Group', and 'GroupDescriptor'.

.EXAMPLE
    Initialize-CacheObject -CacheType Project
    Initializes the cache object for the 'Project' cache type.

.NOTES
#>
Function Initialize-CacheObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'GroupDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]$CacheType
    )

    try {

        # If the cache group is LiveGroups or LiveProjects, set the cache file path to the temporary directory
        if ($CacheType -eq 'LiveGroups' -or $CacheType -eq 'LiveProjects') {
            $cacheFilePath = Join-Path -Path $env:TEMP -ChildPath ".clixml"
            Write-Verbose "[Initialize-CacheObject] Cache file path: $cacheFilePath"
        } else {
            Write-Verbose "[Initialize-CacheObject] Cache file path: $cacheFilePath"
            $cacheFilePath = Join-Path -Path $PSScriptRoot -ChildPath "Cache\.clixml"
        }

        # Test if the Cache File exists. If it does, import the cache object
        if (Test-Path -Path $cacheFilePath) {

            Write-Verbose "[Initialize-CacheObject] Cache file found. Importing cache object for '$CacheType'."
            Import-CacheObject @PSBoundParameters

        } else {

            # If the cache file does not exist, create a new cache object
            Write-Verbose "[Initialize-CacheObject] Cache file not found. Creating new cache object for '$CacheType'."
            Set-CacheObject @PSBoundParameters -Content @()

        }

    } catch {
        Write-Verbose "An error occurred: $_"
        throw "Failed to import cache for Azure DevOps API: $_"
    }

}