<#
.SYNOPSIS
Sets a cache object for Azure DevOps API.

.DESCRIPTION
The Set-CacheObject function is used to set a cache object for Azure DevOps API. It creates a cache directory if it does not exist, saves the content to a cache file, and sets the content to a global variable.

.PARAMETER CacheType
Specifies the type of cache object. Valid values are 'Project', 'Team', 'Group', and 'GroupDescriptor'.

.PARAMETER Content
Specifies the content to be cached. This should be an array of objects.

.PARAMETER Depth
Specifies the depth of the object to be serialized. Default value is 3.

.PARAMETER CacheRootPath
Specifies the root path for the cache directory. Default value is the script root path.

.EXAMPLE
Set-CacheObject -CacheType 'Project' -Content $projectData -Depth 2

This example sets a cache object for the 'Project' type with the provided project data, using a serialization depth of 2.

.INPUTS
None.

.OUTPUTS
None.

.NOTES
Author: Your Name
Date: MM/DD/YYYY
#>

function Set-CacheObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Project','Team', 'Group', 'GroupDescriptor', 'LiveGroups', 'LiveProjects')]
        [string]$CacheType,

        [Parameter(Mandatory)]
        [Object[]]$Content,

        [Parameter()]
        [int]$Depth = 3,

        [Parameter()]
        [String]$CacheRootPath = $PSScriptRoot
    )

    # Write initial verbose message
    Write-Verbose "[Set-ObjectCache] Starting to set cache object for type: $CacheType"

    try {
        # Create cache directory if it does not exist
        $cachePath = Join-Path -Path $CacheRootPath -ChildPath 'Cache'
        if (-not (Test-Path -Path $cachePath)) {
            Write-Verbose "[Set-ObjectCache] Creating cache directory at path: $cachePath"
            New-Item -Path $cachePath -ItemType Directory | Out-Null
        }

        # Create cache file
        $cacheFile = Join-Path -Path $cachePath -ChildPath "$CacheType.clixml"
        Write-Verbose "[Set-ObjectCache] Cache file will be created at path: $cacheFile"

        # Save content to cache file
        Write-Verbose "[Set-ObjectCache] Saving content to cache file"
        $Content | Export-Clixml -Depth $Depth | Set-Content -Path $cacheFile -Force

        # Save content to global variable
        Write-Verbose "[Set-ObjectCache] Setting global variable AzDo$CacheType with the provided content"
        Set-Variable -Name "AzDo$CacheType" -Value $Content -Scope Global -Force

        Write-Verbose "[Set-ObjectCache] Successfully set cache object for type: $CacheType"

    } catch {
        Write-Error "[Set-ObjectCache] Failed to create cache for Azure DevOps API: $_"
        throw
    }
}
