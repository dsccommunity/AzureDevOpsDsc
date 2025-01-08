<#
.SYNOPSIS
Sets a cache object for Azure DevOps API.

.DESCRIPTION
The Set-CacheObject function is used to set a cache object for Azure DevOps API. It creates a cache directory if it does not exist, saves the content to a cache file, and sets the content to a global variable.

.PARAMETER CacheType
Specifies the type of cache object. Valid values are 'Project', 'Team', 'Group', and 'SecurityDescriptor'.

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
Author: Michael Zanatta
Date: 2025-01-06
#>

function Set-CacheObject
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({$_ -in (Get-AzDoCacheObjects)})]
        [string]$CacheType,

        [Parameter()]
        [AllowEmptyCollection()]
        [Object[]]$Content,

        [Parameter()]
        [int]$Depth = 3
    )

    # Write initial verbose message
    Write-Verbose "[Set-ObjectCache] Starting to set cache object for type: $CacheType"

    try
    {
        # Save content to cache file
        Write-Verbose "[Set-ObjectCache] Exporting content to cache file for type: $CacheType"
        Export-CacheObject -CacheType $CacheType -Content $Content -Depth $Depth

        # Save content to global variable
        Write-Verbose "[Set-ObjectCache] Setting global variable AzDo$CacheType with the provided content"
        Set-Variable -Name "AzDo$CacheType" -Value $Content -Scope Global -Force

        Write-Verbose "[Set-ObjectCache] Successfully set cache object for type: $CacheType"

    }
    catch
    {
        throw "[Set-ObjectCache] Failed to create cache for Azure DevOps API: $_"
    }

}
