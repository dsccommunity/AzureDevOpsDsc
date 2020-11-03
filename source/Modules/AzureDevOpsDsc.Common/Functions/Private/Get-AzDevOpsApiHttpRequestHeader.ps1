<#
    .SYNOPSIS
        Generates an API/HTTP request header for use when performing API/HTTP
        requests/operations against the Azure DevOps API.

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .EXAMPLE
        Get-AzDevOpsApiHttpRequestHeader -Pat 'YourPatHere'

        Returns an API/HTTP request header using the 'Personal Access Token' (PAT) provided.
#>
function Get-AzDevOpsApiHttpRequestHeader
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat
    )

    [Hashtable]$apiHttpRequestHeader = @{
        Authorization = 'Basic ' +
            [Convert]::ToBase64String(
                [Text.Encoding]::ASCII.GetBytes(":$Pat"))
    }

    return $apiHttpRequestHeader
}
