<#
.SYNOPSIS
    Unloads and reloads the cache object of the specified type.

.DESCRIPTION
    The Refresh-CacheObject function is used to unload and then reload a cache object of a specified type.
    This can be useful when you need to refresh the state of a cache object to ensure it is up-to-date.

.PARAMETER CacheType
    The type of the cache object to be refreshed. This parameter is mandatory and must be one of the valid cache object types returned by the Get-AzDoCacheObjects function.

.EXAMPLE
    Refresh-CacheObject -CacheType 'Project'
    This example unloads and reloads the cache object of type 'Project'.

.NOTES
    The function uses the Remove-Variable cmdlet to unload the cache object and the Import-CacheObject function to reload it.
    Verbose messages are written to provide feedback on the unloading and reloading process.

#>
# Unloads and reloads the cache object of the specified type.
Function Refresh-CacheObject
{
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({$_ -in (Get-AzDoCacheObjects)})]
        [string]
        $CacheType
    )

    Write-Verbose "[Refresh-CacheObject] Unloading the cache object of type '$CacheType'."

    # Unload the current cache object
    Remove-Variable -Name "AzDo$CacheType" -Scope Global -ErrorAction SilentlyContinue

    Write-Verbose "[Refresh-CacheObject] Reloading the cache object of type '$CacheType'."

    # Reload the cache object
    Import-CacheObject -CacheType $CacheType

}

