<#
.SYNOPSIS
Retrieves a cache object of a specified type.

.DESCRIPTION
The Get-CacheObject function is used to retrieve a cache object of a specified type. It first checks if the cache object is available in memory, and if not, it attempts to import it. The function supports different cache types such as Project, Team, Group, and GroupDescriptor.

.PARAMETER CacheType
Specifies the type of cache object to retrieve. Valid values are 'Project', 'Team', 'Group', and 'GroupDescriptor'.

.PARAMETER CacheRootPath
Specifies the root path of the cache. By default, it uses the path of the current script.

.EXAMPLE
Get-CacheObject -CacheType Project
Retrieves the cache object of type 'Project'.

.EXAMPLE
Get-CacheObject -CacheType Team -CacheRootPath "C:\Cache"
Retrieves the cache object of type 'Team' from the specified root path.

.INPUTS
None.

.OUTPUTS
The cache object of the specified type.

.NOTES
This function is part of the AzureDevOpsDsc module.

.LINK
https://github.com/Azure/AzureDevOpsDsc

#>
function Get-CacheObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Project', 'Team', 'Group', 'GroupDescriptor')]
        [string]$CacheType,

        [Parameter()]
        [String]$CacheRootPath = $PSScriptRoot
    )

    # Write initial verbose message
    Write-Verbose "[Get-ObjectCache] Attempting to retrieve cache object for type: $CacheType"

    try {
        # Attempt to get the variable from the global scope
        $var = Get-Variable -Name "AzDo$CacheType" -Scope Global -ErrorAction SilentlyContinue

        if ($var) {
            Write-Verbose "[Get-ObjectCache] Cache object found in memory for type: $CacheType"
        } else {
            Write-Verbose "[Get-ObjectCache] Cache object not found in memory, attempting to import for type: $CacheType"
            $var = Import-CacheObject @PSBoundParameters
        }

        # Return the content of the cache after importing it
        Write-Verbose "[Get-ObjectCache] Returning imported cache object for type: $CacheType"
        return $var

    } catch {
        Write-Error "[Get-ObjectCache] Failed to get cache for Azure DevOps API: $_"
        throw
    }
}
