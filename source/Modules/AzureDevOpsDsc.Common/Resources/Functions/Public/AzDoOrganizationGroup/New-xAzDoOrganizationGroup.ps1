Function New-xAzDoOrganizationGroup {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
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
    # Create a new group
    $group = New-DevOpsGroup -GroupName $GroupName -GroupDescription $GroupDescription

    @{
        GroupName = $GroupName
        GroupDescription = $GroupDescription
        LookupResult = $LookupResult
    } | Export-Clixml "C:\Temp\newgroup.clixml"

    #
    # Add the group to the cache
    Add-CacheItem -Key $group.principalName -Value $group -Type 'LiveGroups'
    Set-CacheObject -Content $Global:AZDOLiveGroups -CacheType 'LiveGroups'

    Add-CacheItem -Key $group.principalName -Value $group -Type 'Groups'
    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Groups'

}
