Function List-DevOpsGroups {
    [CmdletBinding()]
    [OutputType([System.Object])]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $Organization,
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://vssps.dev.azure.com/$Organization/_apis/graph/groups"
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $groups = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $groups.value) {
        return $null
    }

    #
    # Perform a lookup to get the group

    #
    # Return the groups from the cache
    return $groups.Value

}
