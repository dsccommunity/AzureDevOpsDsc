Function Set-xAzDoOrganizationGroup {

    param(

        [Parameter(Mandatory)]
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
    if ($LookupResult.Status -eq [DSCGetSummaryState]::Renamed) {

        # For the time being write a warning and return
        Write-Warning "[Set-xAzDoOrganizationGroup] The group has been renamed. The group will not be set."
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
    # Update the cache with the new group
    Refresh-CacheIdentity -Identity $group -Key $group.principalName -CacheType 'LiveGroups'

    #
    # Secondarily Replace the local cache with the new group

    if ($null -ne $LookupResult.localCache) {
        Remove-CacheItem -Key $LookupResult.localCache.principalName -Type 'Group'
    }
    Add-CacheItem -Key $group.principalName -Value $group -Type 'Group'
    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Group'

    #
    # Return the group from the cache
    return $group

}
