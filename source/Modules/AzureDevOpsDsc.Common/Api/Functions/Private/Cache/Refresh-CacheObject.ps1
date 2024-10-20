# Unloads and reloads the cache object of the specified type.
Function Refresh-CacheObject {
    param (
        [Parameter(Mandatory)]
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

