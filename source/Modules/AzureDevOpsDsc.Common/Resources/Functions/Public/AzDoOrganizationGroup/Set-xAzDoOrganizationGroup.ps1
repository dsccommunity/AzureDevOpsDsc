Function Set-xAzDoOrganizationGroup {

    param(

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('DisplayName')]
        [System.String]$GroupDisplayName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription,

        [Parameter()]
        [Alias('Lookup')]
        [System.String]$LookupResult

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
