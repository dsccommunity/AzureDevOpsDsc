Function Get-AzDoOrganizationGroup {

    #
    # Check the cache for the group

    $group = Get-CacheItem -Key $Key -Type 'Group'

    #
    # If the group is not in the internal-cache, get the group from the API

    if ($null -eq $group) {
        $group = Get-CacheItem -Key $Key -Type 'LiveGroups'
    }

    #
    # If the group exists, add the group to the cache

    if ($null -ne $group) {
        Add-CacheItem -Key $Key -Value $group -Type 'Group'
    }

    #
    # Return the group from the cache

    return $group.Value

}
