function List-DevOpsGroupMembers
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Organization,
        [Parameter(Mandatory)]
        [String]
        $URL,
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = $URL
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $membership = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $groups.value) {
        return $null
    }

    #
    # Return the groups from the cache
    return $groups.Value


}
