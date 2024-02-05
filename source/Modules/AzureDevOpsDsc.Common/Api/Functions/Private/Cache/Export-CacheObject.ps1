<#
.SYNOPSIS
Exports content to a cache file and saves it to a global variable.

.DESCRIPTION
The Export-CacheObject function exports content to a cache file and saves it to a global variable. It is used in the AzureDevOpsDsc module for caching Azure DevOps API responses.

.PARAMETER CacheType
Specifies the type of cache. Valid values are 'Project', 'Team', 'Group', and 'GroupDescriptor'.

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
        [ValidateSet('Project', 'Team', 'Group', 'GroupDescriptor')]
        [string]$CacheType,

        [Parameter(Mandatory)]
        [Object[]]$Content,

        [Parameter()]
        [int]$Depth = 3,

        [Parameter()]
        [String]$CacheRootPath = $PSScriptRoot
    )

    # Write initial verbose message
    Write-Verbose "[Export-ObjectCache] Starting export process for cache type: $CacheType"

    try {
        # Create cache directory if it does not exist
        $cachePath = Join-Path -Path $CacheRootPath -ChildPath 'Cache'
        if (-not (Test-Path -Path $cachePath)) {
            Write-Verbose "[Export-ObjectCache] Creating cache directory at path: $cachePath"
            New-Item -Path $cachePath -ItemType Directory | Out-Null
        }

        # Create cache file path
        $cacheFile = Join-Path -Path $cachePath -ChildPath "$CacheType.clixml"

        # Save content to cache file
        Write-Verbose "[Export-ObjectCache] Saving content to cache file: $cacheFile"
        $Content | Export-Clixml -Depth $Depth | Set-Content -Path $cacheFile -Force

        # Save content to global variable
        Write-Verbose "[Export-ObjectCache] Saving content to global variable: AzDo$CacheType"
        Set-Variable -Name "AzDo$CacheType" -Value $Content -Scope Global -Force

        # Confirm completion of export process
        Write-Verbose "[Export-ObjectCache] Export process completed successfully for cache type: $CacheType"

    } catch {
        Write-Error "[Export-ObjectCache] Failed to create cache for Azure DevOps API: $_"
        throw
    }
}
