<#
.SYNOPSIS
Removes an Azure DevOps project group.

.DESCRIPTION
The Remove-AzDoProjectGroup function removes a specified Azure DevOps project group by its name and project.
It also updates the cache to reflect the removal.

.PARAMETER GroupName
The name of the group to be removed. This parameter is mandatory.

.PARAMETER GroupDescription
The description of the group to be removed. This parameter is optional.

.PARAMETER ProjectName
The name of the project that the group belongs to. This parameter is mandatory.

.PARAMETER LookupResult
A hashtable containing the lookup results for the group. This parameter is optional.

.PARAMETER Ensure
Specifies whether the group should be present or absent. This parameter is optional.

.PARAMETER Force
A switch parameter to force the removal of the group without confirmation. This parameter is optional.

.EXAMPLE
Remove-AzDoProjectGroup -GroupName "Developers" -ProjectName "MyProject"

This command removes the "Developers" group from the "MyProject" project.

#>
Function Remove-AzDoProjectGroup
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

        [Parameter(Mandatory = $true)]
        [Alias('Project')]
        [System.String]$ProjectName,

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
