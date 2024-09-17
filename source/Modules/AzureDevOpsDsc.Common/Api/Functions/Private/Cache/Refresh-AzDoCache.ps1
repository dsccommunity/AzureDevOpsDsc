Function Refresh-AzDoCache {
    param(
        [Parameter(Mandatory)]
        [string]$OrganizationName
    )

    # Clear the live cache
    Get-Variable Azdo* -Scope Global | Remove-Variable -Scope Global

    # Iterate through Each of the Caching Commands and initalize the Cache.
    Get-Command "AzDoAPI_*" | Where-Object Source -eq 'AzureDevOpsDsc.Common' | ForEach-Object {
        . $_.Name -OrganizationName $OrganizationName
    }

    # ReImport the Cache
    Get-AzDoCacheObjects | ForEach-Object {
        Import-CacheObject -CacheType $_
    }


}
