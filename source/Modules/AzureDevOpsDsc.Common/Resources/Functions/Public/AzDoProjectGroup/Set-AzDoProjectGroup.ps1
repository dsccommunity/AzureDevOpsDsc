<#
.SYNOPSIS
Sets or updates an Azure DevOps project group.

.DESCRIPTION
The Set-AzDoProjectGroup function sets or updates an Azure DevOps project group based on the provided parameters.
It handles renaming, updating group details, and managing cache for the group.

.PARAMETER GroupName
The name of the Azure DevOps project group. This parameter is mandatory.

.PARAMETER GroupDescription
The description of the Azure DevOps project group. This parameter is optional.

.PARAMETER ProjectName
The name of the Azure DevOps project. This parameter is mandatory.

.PARAMETER LookupResult
A hashtable containing the lookup result for the group. This parameter is optional.

.PARAMETER Ensure
Specifies whether the group should be present or absent. This parameter is optional.

.PARAMETER Force
A switch parameter to force the operation. This parameter is optional.

.EXAMPLE
Set-AzDoProjectGroup -GroupName "Developers" -ProjectName "MyProject" -GroupDescription "Development Team"

This example sets or updates the "Developers" group in the "MyProject" Azure DevOps project with the description "Development Team".

.NOTES
If the group has been renamed, a warning is issued and the function returns without making changes.
The function updates both the live and local cache with the new group details.
#>
Function Set-AzDoProjectGroup
{
    param(
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

    #
    # Depending on the type of lookup status, the group has been renamed the group has been deleted and recreated.
    if ($LookupResult.Status -eq [DSCGetSummaryState]::Renamed)
    {
        # For the time being write a warning and return
        Write-Warning "[Set-AzDoProjectGroup] The group has been renamed. The group will not be set."
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
    # Firstly Replace the live cache with the new group

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
