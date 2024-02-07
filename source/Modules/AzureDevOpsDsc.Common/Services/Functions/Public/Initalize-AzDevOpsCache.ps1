<#
.SYNOPSIS
    Initializes the cache for Azure DevOps resources.

.DESCRIPTION
    This function initializes the cache for Azure DevOps resources by loading the cache from a file for each type.
    The cache types include Project, Team, Group, and SecurityDescriptor.

.PARAMETER None
    This function does not accept any parameters.

.EXAMPLE
    Initialize-Cache
    Initializes the cache for Azure DevOps resources.

.NOTES

#>
function Initialize-Cache {
    [CmdletBinding()]
    param ()

    # Write initial verbose message
    Write-Verbose "[Initialize-Cache] Starting cache initialization process."

    try {
        # Attempt to load the cache from the file for each type
        $cacheTypes = @('Project', 'Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')
        foreach ($cacheType in $cacheTypes) {
            Write-Verbose "[Initialize-Cache] Initializing cache object of type: $cacheType"
            Initialize-CacheObject -CacheType $cacheType
        }

        # Confirm completion of cache initialization
        Write-Verbose "[Initialize-Cache] Cache initialization process completed successfully."

    } catch {

        Write-Error "[Initialize-Cache] An error occurred during cache initialization: $_"
        throw

    }
}
