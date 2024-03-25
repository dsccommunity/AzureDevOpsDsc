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
        # Specifies the type of cache to initialize. Valid values are 'Project', 'Team', 'Group', and 'SecurityDescriptor'.
        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]$CacheType,
        # Used to bypass the file deletion check for live caches. Needed for DSC Resources to import the cache.
        [Parameter()]
        [Switch]$BypassFileCheck

    )

    try {

        # Use the Enviroment Variables to set the Cache Directory Path
        if ($ENV:AZDODSC_CACHE_DIRECTORY) {
            $CacheDirectoryPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "Cache"
        } else {
            Throw "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the variable to the path of the cache directory."
        }

        $cacheFilePath = Join-Path -Path $CacheDirectoryPath -ChildPath "$CacheType.clixml"
        Write-Verbose "[Initialize-CacheObject] Cache file path: $cacheFilePath"

        # If the cache group is LiveGroups or LiveProjects, set the cache file path to the temporary directory
        if (-not($BypassFileCheck.IsPresent) -and (($CacheType -eq 'LiveGroups') -or ($CacheType -eq 'LiveProjects'))) {

            # Flush the cache if it is a live cache
            if (Test-Path -LiteralPath $cacheFilePath -ErrorAction SilentlyContinue) {
                Write-Verbose "[Initialize-CacheObject] Cache file found. Removing cache file for '$CacheType'."
                Remove-Item -LiteralPath $cacheFilePath -Force
            }

        } else {
            # Test if the Cache File exists. If it exists, import the cache object
            Write-Verbose "[Initialize-CacheObject] Cache file path: $cacheFilePath"
        }

        # Test if the Cache File exists. If it exists, import the cache object
        if (Test-Path -Path $cacheFilePath) {

            # If the cache file exists, import the cache object
            Write-Verbose "[Initialize-CacheObject] Cache file found. Importing cache object for '$CacheType'."
            Import-CacheObject -CacheType $CacheType

        } else {

            # If the cache file does not exist, create a new cache object
            Write-Verbose "[Initialize-CacheObject] Cache file not found. Creating new cache object for '$CacheType'."

            # Create the cache directory if it does not exist
            if (-not (Test-Path -Path $CacheDirectoryPath)) {
                Write-Verbose "[Initialize-CacheObject] Cache directory not found. Creating cache directory."
                New-Item -Path $CacheDirectoryPath -ItemType Directory | Out-Null
            }

            # Create the content
            $content = [System.Collections.Generic.List[CacheItem]]::New()

            # Create a new cache object
            Set-CacheObject -CacheType $CacheType -Content $content

        }

    } catch {
        Write-Verbose "An error occurred: $_"
        throw "[Initialize-CacheObject] Failed to import cache for Azure DevOps API: $_"
    }

}
