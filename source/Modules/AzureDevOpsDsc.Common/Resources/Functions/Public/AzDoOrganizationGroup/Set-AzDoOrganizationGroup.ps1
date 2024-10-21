<#
.SYNOPSIS
Sets or updates an Azure DevOps organization group.

.DESCRIPTION
The Set-AzDoOrganizationGroup function sets or updates an Azure DevOps organization group based on the provided parameters.
It handles renaming, updating group details, and managing cache updates.

.PARAMETER GroupName
Specifies the name of the group to be set or updated. This parameter is mandatory.

.PARAMETER GroupDescription
Specifies the description of the group to be set or updated. This parameter is optional.

.PARAMETER LookupResult
A hashtable containing the lookup result, which includes the status and cache information of the group. This parameter is optional.

.PARAMETER Ensure
Specifies the desired state of the group. This parameter is optional.

.PARAMETER Force
A switch parameter that forces the operation to proceed without confirmation. This parameter is optional.

.EXAMPLE
Set-AzDoOrganizationGroup -GroupName "Developers" -GroupDescription "Development Team" -LookupResult $lookupResult

This example sets or updates the "Developers" group with the description "Development Team" using the provided lookup result.

.NOTES
If the group has been renamed, a warning is written and the function returns without making any changes.
The function updates the group using the Azure DevOps API and refreshes the cache with the new group information.
#>

Function Set-AzDoOrganizationGroup
{
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription,

        [Parameter()]
        [Alias('Lookup')]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    #
    # Depending on the type of lookup status, the group has been renamed the group has been deleted and recreated.
    if ($LookupResult.Status -eq [DSCGetSummaryState]::Renamed)
    {
        # For the time being write a warning and return
        Write-Warning "[Set-AzDoOrganizationGroup] The group has been renamed. The group will not be set."
        return
    }

    #
    # Update the group
    $params = @{
        ApiUri = 'https://vssps.dev.azure.com/{0}' -f $Global:DSCAZDO_OrganizationName
        GroupName = $GroupName
        GroupDescription = $GroupDescription
        GroupDescriptor = $LookupResult.liveCache.descriptor
    }

    try
    {
        # Set the group from the API
        $group = Set-DevOpsGroup @params
    }
    catch
    {
        throw $_
    }

    #
    # Update the cache with the new group
    Refresh-CacheIdentity -Identity $group -Key $group.principalName -CacheType 'LiveGroups'

    #
    # Secondarily Replace the local cache with the new group

    if ($null -ne $LookupResult.localCache)
    {
        Remove-CacheItem -Key $LookupResult.localCache.principalName -Type 'Group'
    }

    Add-CacheItem -Key $group.principalName -Value $group -Type 'Group'
    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Group'

    #
    # Return the group from the cache
    return $group

}
