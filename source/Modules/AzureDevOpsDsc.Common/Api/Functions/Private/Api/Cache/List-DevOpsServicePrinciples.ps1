Function List-DevOpsServicePrinciples {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://vssps.dev.azure.com/$OrganizationName/_apis/graph/serviceprincipals"
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $serviceprincipals = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $serviceprincipals.value)
    {
        return $null
    }

    #
    # Return the groups from the cache
    return $serviceprincipals.Value


}
