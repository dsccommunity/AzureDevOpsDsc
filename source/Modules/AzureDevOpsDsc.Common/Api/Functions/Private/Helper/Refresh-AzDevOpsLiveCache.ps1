Function Refresh-AzDevOpsLiveCache {
    [CmdletBinding()]
    [OutputType([System.Object])]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateSet('LiveGroups', 'LiveProjects')]
        [string]
        $Type
    )

    #
    # If the Type is LiveGroups, get the groups from the API

    if ($Type -eq 'LiveGroups') {
        $groups = List-AzDevOpsGroups @PSBoundParameters -OrganizationName $Global:DSCAZDO_OrganizationName
        foreach ($group in $groups) {
            Add-CacheItem -Key $group.Key -Value $group -Type 'Group'
        }
    }

    #
    #

    #
    # Add the value to the cache



    Add-CacheItem -Key $Key -Value $Value -Type $Type
}

