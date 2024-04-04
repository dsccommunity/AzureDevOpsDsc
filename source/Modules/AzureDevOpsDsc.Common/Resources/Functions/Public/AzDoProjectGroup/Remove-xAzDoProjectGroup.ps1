Function Remove-xAzDoProjectGroup {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription,

        [Parameter(Mandatory)]
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
    if (($null -eq $LookupResult.liveCache) -and ($null -eq $LookupResult.localCache)) {
        return
    }

    $params = @{
        GroupDescriptor = $LookupResult.liveCache.Descriptor
        ApiUri = "https://vssps.dev.azure.com/{0}" -f $Global:DSCAZDO_OrganizationName
    }

    $cacheItem = @{
        Key = $LookupResult.liveCache.principalName
    }

    # If the group is not found, return
    if (($null -ne $LookupResult.localCache) -and ($null -eq $LookupResult.liveCache)) {
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
