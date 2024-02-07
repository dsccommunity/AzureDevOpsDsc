Function Remove-AzDoOrganizationGroup {

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
        [System.String]$GroupDisplayName

    )

    #
    # Format the Key According to the Principal Name

    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupDisplayName

    #
    # Check if the group exists in the live cache.

    $group = Get-CacheItem -Key $Key -Type 'LiveGroups'

    if ($null -eq $group) {
        $group = Get-AzDoOrganizationGroup -ApiUri $ApiUri -Pat $Pat -GroupDisplayName $GroupDisplayName
    }

    #
    # Remove the group from the API

    $params = @{
        ApiUri = $ApiUri
        GroupDescriptor = $group.Descriptor
    }

    # Remove the group from the API
    $null = Remove-AzDevOpsGroup @params

    #
    # Remove the group from the cache and live cache

    Remove-CacheItem -Key $Key -Type 'Group'
    Remove-CacheItem -Key $Key -Type 'LiveGroups'

}
