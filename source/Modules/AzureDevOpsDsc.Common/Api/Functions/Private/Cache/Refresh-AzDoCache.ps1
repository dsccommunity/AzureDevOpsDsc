<#
.SYNOPSIS
Refreshes the Azure DevOps cache by clearing existing cache variables and reinitializing them.

.DESCRIPTION
The Refresh-AzDoCache function clears the current Azure DevOps cache variables and reinitializes them by invoking all caching commands from the AzureDevOpsDsc.Common module. It then reimports the cache objects to ensure the cache is up-to-date.

.PARAMETER OrganizationName
Specifies the name of the Azure DevOps organization for which the cache should be refreshed. This parameter is mandatory.

.EXAMPLE
Refresh-AzDoCache -OrganizationName "MyOrganization"
This example refreshes the Azure DevOps cache for the organization named "MyOrganization".

.NOTES
This function is intended for internal use within the AzureDevOpsDsc.Common module to maintain the integrity of the cache.

#>
Function Refresh-AzDoCache
{
    param(
        [Parameter(Mandatory = $true)]
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
