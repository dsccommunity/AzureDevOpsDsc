<#
.SYNOPSIS
Initializes and caches the permissions for Azure DevOps security namespaces.

.DESCRIPTION
The `AzDoAPI_5_PermissionsCache` function retrieves the security namespaces for a specified Azure DevOps organization and caches the permissions.
If no organization name is provided, it uses a global variable for the organization name. The function then exports the cached permissions to a file.

.PARAMETER OrganizationName
The name of the Azure DevOps organization. This parameter is optional. If not provided, the function uses the global variable `$Global:DSCAZDO_OrganizationName`.

.EXAMPLE
AzDoAPI_5_PermissionsCache -OrganizationName "MyOrganization"
This example initializes and caches the permissions for the "MyOrganization" Azure DevOps organization.

.EXAMPLE
AzDoAPI_5_PermissionsCache
This example initializes and caches the permissions using the global organization name variable.

.NOTES
This function requires the `List-DevOpsSecurityNamespaces`, `Add-CacheItem`, and `Export-CacheObject` cmdlets to be available in the session.
#>
function AzDoAPI_5_PermissionsCache
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$OrganizationName
    )

    #
    # Use a verbose statement to indicate the start of the function.

    Write-Verbose "[AzDoAPI_5_PermissionsCache] Started."

    if (-not $OrganizationName)
    {
        Write-Verbose "[AzDoAPI_5_PermissionsCache] No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    #
    # List the security namespaces

    $securityNamespaces = List-DevOpsSecurityNamespaces -OrganizationName $OrganizationName

    #
    # Iterate through each security namespace and export the permissions to the cache
    foreach ($securityNamespace in $securityNamespaces)
    {
        $securityNamespaceName = $securityNamespace.name
        $value = $securityNamespace | Select-Object namespaceId, name, displayName, writePermission, readPermision, dataspaceCategory, actions

        # Add the project to the cache with its name as the key
        Add-CacheItem -Key $securityNamespaceName -Value $value -Type 'SecurityNamespaces'
    }

    # Export the cache to a file
    Export-CacheObject -CacheType 'SecurityNameSpaces' -Content $AzDoSecurityNameSpaces -Depth 5

}
