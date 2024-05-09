function List-DevOpsGroupMembers
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Organization,
        [Parameter(Mandatory)]
        [String]
        $GroupDescriptor,
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://vssps.dev.azure.com/{0}/_apis/graph/Memberships/{1}?direction=down" -f $Organization, $GroupDescriptor
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $membership = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $membership.value) {
        return $null
    }

    #
    # Return the groups from the cache
    return $groups.Value

}
