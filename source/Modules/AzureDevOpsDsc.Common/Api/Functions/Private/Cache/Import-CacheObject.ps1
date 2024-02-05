<#
.SYNOPSIS
Imports a cache object for Azure DevOps API.

.DESCRIPTION
The Import-CacheObject function is used to import a cache object for Azure DevOps API. It checks if the cache file exists and imports its content if found. The cache object is then stored in a global variable.

.PARAMETER CacheType
Specifies the type of cache object to import. Valid values are 'Project', 'Team', 'Group', and 'GroupDescriptor'.

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
Author: Your Name
Date: Current Date
#>

function Import-CacheObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Project', 'Team', 'Group', 'GroupDescriptor')]
        [string]$CacheType,

        [Parameter()]
        [String]$CacheRootPath = $PSScriptRoot
    )

    # Write initial verbose message
    Write-Verbose "[Import-ObjectCache] Starting to import cache object for type: $CacheType"

    try {
        # Determine cache directory path
        $cachePath = Join-Path -Path $CacheRootPath -ChildPath 'Cache'

        # Create cache directory if it does not exist
        if (-not (Test-Path -Path $cachePath)) {
            Write-Verbose "[Import-ObjectCache] Creating cache directory at path: $cachePath"
            New-Item -Path $cachePath -ItemType Directory | Out-Null
        }

        # Determine cache file path
        $cacheFile = Join-Path -Path $cachePath -ChildPath "$CacheType.clixml"

        # Import content from cache file if it exists
        if (Test-Path -Path $cacheFile) {
            Write-Verbose "[Import-ObjectCache] Importing content from cache file at path: $cacheFile"
            $Content = Import-Clixml -Path $cacheFile
            Set-Variable -Name "AzDo$CacheType" -Value $Content -Scope Global -Force
            Write-Verbose "[Import-ObjectCache] Successfully imported cache object for type: $CacheType"
        } else {
            Write-Error "[Import-ObjectCache] Cache file not found for Azure DevOps API: $CacheType"
        }

    } catch {
        Write-Error "[Import-ObjectCache] Failed to import cache for Azure DevOps API: $_"
        throw
    }
}
