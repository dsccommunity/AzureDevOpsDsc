
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
        Uri = "https://vssps.dev.azure.com/$Organization/_apis/projects"
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
