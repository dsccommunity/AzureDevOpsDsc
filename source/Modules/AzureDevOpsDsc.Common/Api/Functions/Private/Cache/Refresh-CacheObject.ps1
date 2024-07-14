Function Refresh-CacheObject {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({$_ -in (Get-AzDoCacheObjects)})]
        [string]
        $Type
    )

    #     Write-Verbose "[Refresh-CacheObject] Retrieving the current cache."

}

