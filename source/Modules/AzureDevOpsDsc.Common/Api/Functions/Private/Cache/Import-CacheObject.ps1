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


This example imports the cache object for the 'Project' type from the cache directory located at "C:\Cache".

.INPUTS
None.

.OUTPUTS
None.

.NOTES
#>

function Import-CacheObject
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'SecurityDescriptor', 'LiveGroups', 'LiveProjects', 'LiveUsers', 'LiveGroupMembers')]
        [string]$CacheType

    )

    # Write initial verbose message
    Write-Verbose "[Import-CacheObject] Starting to import cache object for type: $CacheType"

    # Use the Enviroment Variables to set the Cache Directory Path
    if ($ENV:AZDODSC_CACHE_DIRECTORY) {
        $CacheDirectoryPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "Cache"
    } else {
        Throw "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the variable to the path of the cache directory."
    }

    Write-Verbose "[Import-CacheObject] Cache root path: $CacheDirectoryPath"

    try
    {
        # Determine cache file path
        $cacheFile = Join-Path -Path $CacheDirectoryPath -ChildPath "$CacheType.clixml"

        # Check if cache file exists
        if (-not (Test-Path -Path $cacheFile))
        {
            Write-Warning "[Import-CacheObject] Cache file not found at path: $cacheFile"
        }

        Write-Verbose "[Import-CacheObject] Importing content from cache file at path: $cacheFile"

        $Content = Import-Clixml -Path $cacheFile

        #Set-Variable -Name "AzDo$CacheType" -Value $Content -Scope Global -Force
        Write-Verbose "[Import-CacheObject] Successfully imported cache object for type: $cacheFile"

        # Convert the imported cache object to a list of CacheItem objects
        $newCache = [System.Collections.Generic.List[CacheItem]]::New()

        # If the content is null, skip!
        if ($null -ne $Content)
        {
            $Content | ForEach-Object {
                # If the key is empty, skip the item
                if ([string]::IsNullOrEmpty($_.Key)) { return }

                # Create a new CacheItem object and add it to the list
                $newCache.Add([CacheItem]::New($_.Key, $_.Value))
            }
        }

        # Update the new cache object
        Set-Variable -Name "AzDo$CacheType" -Value $newCache -Scope Global -Force
        Write-Verbose "[Import-CacheObject] Cache object imported successfully for '$CacheType'."

    } catch
    {
        Write-Error "[Import-CacheObject] Failed to import cache for Azure DevOps API: $_"
        throw $_
    }
}
