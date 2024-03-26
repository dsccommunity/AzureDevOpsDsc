Function Set-xAzDoOrganizationGroup {

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter()]
        [string]
        $GroupDescription=$null,

        [Parameter()]
        [string]
        $GroupDisplayName=$null

    )

    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupName

    #
    # Check the live group cache
    $LiveGroups = Get-CacheItem -Key $Key -Type 'LiveGroups'

    #
    # Check the local group cache
    $localgroup = Get-CacheItem -Key $Key -Type 'Group'

    #
    #

    $params = @{
        ApiUri = $ApiUri
        Pat = $Pat
        GroupName = $GroupName
        GroupDescription = $GroupDescription
    }

    # Set the group from the API
    $null = Set-DevOpsGroup @params


    #
    # Return the group from the cache

    return $group.Value

}
