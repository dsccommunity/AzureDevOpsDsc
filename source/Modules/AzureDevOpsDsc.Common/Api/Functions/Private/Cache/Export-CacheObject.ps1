<#
.SYNOPSIS
Exports content to a cache file and saves it to a global variable.

.DESCRIPTION
The Export-CacheObject function exports content to a cache file and saves it to a global variable. It is used in the AzureDevOpsDsc module for caching Azure DevOps API responses.

.PARAMETER CacheType
Specifies the type of cache. Valid values are 'Project', 'Team', 'Group', and 'SecurityDescriptor'.

.PARAMETER Content
Specifies the content to be exported to the cache file.

.PARAMETER Depth
Specifies the depth of the object to be exported. Default value is 3.

.PARAMETER CacheRootPath
Specifies the root path where the cache directory will be created. Default value is the script root path.

.EXAMPLE
Export-CacheObject -CacheType 'Project' -Content $projectData
Exports the $projectData content to a cache file and saves it to the global variable 'AzDoProject'.

.INPUTS
None.

.OUTPUTS
None.

.NOTES
This function is part of the AzureDevOpsDsc module and is used for caching Azure DevOps API responses.
#>
Function Export-CacheObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]$CacheType,

        [Parameter()]
        [AllowEmptyCollection()]
        [Object[]]$Content,

        [Parameter()]
        [int]$Depth = 3
    )

    # Write initial verbose message
    Write-Verbose "[Export-ObjectCache] Starting export process for cache type: $CacheType"

    # Use the Enviroment Variables to set the Cache Directory Path
    if ($ENV:AZDODSC_CACHE_DIRECTORY) {
        $CacheDirectoryPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "Cache"
    } else {
        Throw "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the variable to the path of the cache directory."
    }

    try {

        $cacheFilePath = Join-Path -Path $CacheDirectoryPath -ChildPath "$CacheType.clixml"

        # Create cache directory if it does not exist
        if (-not (Test-Path -Path $cacheFilePath)) {
            Write-Verbose "[Export-ObjectCache] Creating cache directory at path: $CacheDirectoryPath"
            New-Item -Path $CacheDirectoryPath -ItemType Directory | Out-Null
        }

        # Save content to cache file
        Write-Verbose "[Export-ObjectCache] Saving content to cache file: $cacheFilePath"
        $Content | Export-Clixml -Depth $Depth -LiteralPath $cacheFilePath

        # Confirm completion of export process
        Write-Verbose "[Export-ObjectCache] Export process completed successfully for cache type: $CacheType"

    } catch {
        Write-Error "[Export-ObjectCache] Failed to create cache for Azure DevOps API: $_"
        throw
    }
}
