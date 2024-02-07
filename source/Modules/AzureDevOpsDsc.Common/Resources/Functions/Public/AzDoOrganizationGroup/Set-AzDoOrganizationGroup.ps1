Function Set-AzDoOrganizationGroup {

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
    # Check the cache for the group

    $group = Get-CacheItem -Key $Key -Type 'Group'

    #
    # If the group is not in the internal-cache, get the group from the API cache

    if ($null -eq $group) {
        $group = Get-CacheItem -Key $Key -Type 'LiveGroups'
    }

    #
    # Return the group from the cache

    return $group.Value

}
