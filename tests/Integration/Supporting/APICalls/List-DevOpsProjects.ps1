
function List-DevOpsProjects
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
        Uri = "https://dev.azure.com/$OrganizationName/_apis/projects"
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $groups = Invoke-APIRestMethod @params

    if ($null -eq $groups.value)
    {
        return $null
    }

    #
    # Return the groups from the cache
    return $groups.Value

}
