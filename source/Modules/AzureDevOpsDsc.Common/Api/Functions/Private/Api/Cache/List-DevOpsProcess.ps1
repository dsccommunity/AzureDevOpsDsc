Function List-DevOpsProcess {
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
        Uri = "https://dev.azure.com/{0}/_apis/process/processes?api-version={1}" -f $Organization, $ApiVersion
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $groups = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $groups.value) {
        return $null
    }

    #
    # Return the groups from the cache
    return $groups.Value

}
