function List-UserCache
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://vssps.dev.azure.com/$OrganizationName/_apis/graph/users"
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $users = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $users.value) {
        return $null
    }

    #
    # Return the groups from the cache
    return $users.Value

}
