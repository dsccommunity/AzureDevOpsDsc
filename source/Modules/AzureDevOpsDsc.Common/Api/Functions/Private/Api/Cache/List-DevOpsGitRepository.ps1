
function List-DevOpsGitRepository
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [String]$ProjectName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://dev.azure.com/$OrganizationName/$ProjectName/_apis/git/repositories"
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $repositories = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $repositories.value)
    {
        return $null
    }

    #
    # Return the groups from the cache
    return $repositories.Value

}
