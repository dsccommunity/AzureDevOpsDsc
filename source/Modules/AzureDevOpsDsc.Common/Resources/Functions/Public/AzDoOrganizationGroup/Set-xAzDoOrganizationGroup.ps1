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
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid -AllowWildcard })]
        [Alias('ProjectName')]
        [System.String]
        $ProjectName,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri
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
