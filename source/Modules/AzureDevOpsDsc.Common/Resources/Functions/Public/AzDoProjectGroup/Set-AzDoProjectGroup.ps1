Function Set-AzDoProjectGroup {

    param(

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

    #
    # Depending on the type of lookup status, the group has been renamed the group has been deleted and recreated.
    if ($LookupResult.Status -eq [DSCGetSummaryState]::Renamed) {

        # For the time being write a warning and return
        Write-Warning "[Set-AzDoProjectGroup] The group has been renamed. The group will not be set."
        return

    }

    #
    # Update the group
    $params = @{
        ApiUri = "https://vssps.dev.azure.com/{0}" -f $Global:DSCAZDO_OrganizationName
        GroupName = $GroupName
        GroupDescription = $GroupDescription
        GroupDescriptor = $LookupResult.liveCache.descriptor
    }

    try {
        # Set the group from the API
        $group = Set-DevOpsGroup @params
    } catch {
        throw $_
    }

    #
    # Firstly Replace the live cache with the new group

    if ($null -ne $LookupResult.liveCache) {
        Remove-CacheItem -Key $LookupResult.liveCache.principalName -Type 'LiveGroups'
    }
    Add-CacheItem -Key $group.principalName -Value $group -Type 'LiveGroups'
    Set-CacheObject -Content $Global:AZDOLiveGroups -CacheType 'LiveGroups'

    #
    # Secondarily Replace the local cache with the new group
    if ($null -ne $LookupResult.localCache) {
        Remove-CacheItem -Key $LookupResult.localCache.principalName -Type 'Groups'
    }
    Add-CacheItem -Key $group.principalName -Value $group -Type 'Groups'
    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Groups'

    #
    # Return the group from the cache
    return $group

}
