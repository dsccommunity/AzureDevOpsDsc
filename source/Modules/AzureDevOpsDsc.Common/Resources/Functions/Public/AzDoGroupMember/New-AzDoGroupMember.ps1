Function New-xAzDoOrganizationGroup {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String[]]$GroupMembers=$null,

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure

    )

    $params = @{
        GroupName = $GroupName
        GroupDescription = $GroupDescription
        ApiUri = "https://vssps.dev.azure.com/{0}" -f $Global:DSCAZDO_OrganizationName
    }

    #
    # Create a new group
    $group = New-DevOpsGroup @params

    #
    # Add the group to the cache
    Add-CacheItem -Key $group.principalName -Value $group -Type 'LiveGroups'
    Set-CacheObject -Content $Global:AZDOLiveGroups -CacheType 'LiveGroups'

    Add-CacheItem -Key $group.principalName -Value $group -Type 'Group'
    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Group'

}
