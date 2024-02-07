Function New-AzDoOrganizationGroup {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter()]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory)]
        [Alias('DisplayName')]
        [System.String]$GroupDisplayName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription

    )


    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupName

    #
    # Check if the group exists in the cache. If it does throw an error.

    $local_group = Get-CacheItem -Key $Key -Type 'Group'
    $online_group = Get-CacheItem -Key $Key -Type 'LiveGroups'

    if ($group) {
        throw "Group with name '$Key' already exists in the cache."
    } elseif ($online_group) {
        throw "Group with name '$Key' already exists in the organization."
    }

    #
    # Create a new group

    $result = New-AzDevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription

    #
    # Add the group to the cache
    Add-CacheItem -Key $Key -Value $result -Type 'Group'

}
