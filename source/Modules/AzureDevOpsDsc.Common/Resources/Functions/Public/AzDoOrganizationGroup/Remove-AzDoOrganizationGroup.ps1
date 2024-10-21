<#
.SYNOPSIS
Removes an Azure DevOps organization group.

.DESCRIPTION
The Remove-AzDoOrganizationGroup function removes a specified Azure DevOps organization group.
It uses the provided group name, description, and lookup result to identify and remove the group
from the Azure DevOps API and local cache.

.PARAMETER GroupName
The name of the group to be removed. This parameter is mandatory.

.PARAMETER GroupDescription
The description of the group to be removed. This parameter is optional.

.PARAMETER LookupResult
A hashtable containing the lookup result for the group. This parameter is optional.

.PARAMETER Ensure
Specifies whether the group should be present or absent. This parameter is optional.

.PARAMETER Force
A switch parameter to force the removal of the group without confirmation. This parameter is optional.

.EXAMPLE
Remove-AzDoOrganizationGroup -GroupName "Developers" -Force

This example removes the "Developers" group from the Azure DevOps organization without confirmation.

.NOTES
This function relies on the global variables $Global:DSCAZDO_OrganizationName, $Global:AZDOLiveGroups,
and $Global:AzDoGroup to interact with the Azure DevOps API and manage cache objects.
#>
Function Remove-AzDoOrganizationGroup
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
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

    # If no cache items exist, return.
    if (($null -eq $LookupResult.liveCache) -and ($null -eq $LookupResult.localCache))
    {
        return
    }

    $params = @{
        GroupDescriptor = $LookupResult.liveCache.Descriptor
        ApiUri = 'https://vssps.dev.azure.com/{0}' -f $Global:DSCAZDO_OrganizationName
    }

    $cacheItem = @{
        Key = $LookupResult.liveCache.principalName
    }

    # If the group is not found, return
    if (($null -ne $LookupResult.localCache) -and ($null -eq $LookupResult.liveCache))
    {
        $cacheItem.Key = $LookupResult.localCache.principalName
        $params.GroupDescriptor = $LookupResult.localCache.Descriptor
    }

    #
    # Remove the group from the API
    $null = Remove-DevOpsGroup @params

    #
    # Remove the group from the API

    Remove-CacheItem @cacheItem -Type 'LiveGroups'
    Set-CacheObject -Content $Global:AZDOLiveGroups -CacheType 'LiveGroups'

    Remove-CacheItem @cacheItem -Type 'Group'
    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Group'

}
