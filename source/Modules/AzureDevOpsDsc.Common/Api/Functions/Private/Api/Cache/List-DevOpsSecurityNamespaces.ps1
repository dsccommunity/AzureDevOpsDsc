Function List-DevOpsSecurityNamespaces {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "[List-DevOpsSecurityNamespaces] Started."

    # Params
    $params = @{
        Uri = "https://dev.azure.com/$OrganizationName/_apis/securitynamespaces/"
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $namespaces = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $namespaces.value)
    {
        return $null
    }

    #
    # Return the groups from the cache
    return $namespaces.Value

}
