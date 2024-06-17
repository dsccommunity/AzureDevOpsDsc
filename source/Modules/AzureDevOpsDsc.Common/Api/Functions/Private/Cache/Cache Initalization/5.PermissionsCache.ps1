function AzDoAPI_5_PermissionsCache
{
    [CmdletBinding()]
    param(
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
