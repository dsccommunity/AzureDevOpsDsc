Function New-xAzDoOrganizationGroup {

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
        [System.String]$GroupDescription,

        [Parameter()]
        [Alias('Name')]
        [System.String]$GetResult

    )


    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupName

    #
    # Create a new group

    $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription

    #
    # Add the group to the cache
    Add-CacheItem -Key $Key -Value $result -Type 'LiveGroups'

}
