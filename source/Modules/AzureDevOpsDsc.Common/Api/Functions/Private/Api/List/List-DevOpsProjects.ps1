
function List-DevOpsProjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://vssps.dev.azure.com/{0}/_apis/projects?api-version={1}" -f $Organization, $ApiVersion
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
