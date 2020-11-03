<#
    .SYNOPSIS
        Returns a full URI for the API resource given the parameter values provided.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER ApiVersion
        The version of the Azure DevOps API to use in the call/execution to/against the API.

    .PARAMETER ResourceName
        The name of the resource being obtained from the Azure DevOps API (e.g. 'Project' or 'Operation')

    .PARAMETER ResourceId
        The 'id' of the resource type being obtained. For example, if the 'ResourceName' parameter value
        was 'Project', the 'ResourceId' value would be assumed to be the 'id' of a 'Project'.

    .EXAMPLE
        Get-AzDevOpsApiResourceUri -ApiUri 'YourApiUriHere' -ResourceName 'Project'

        Returns a URI to obtain all 'Project' resources from the Azure DevOps API related to the Organization/ApiUri
        value provided.

    .EXAMPLE
        Get-AzDevOpsApiResourceUri -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId 'YourProjectId'

        Returns a URI to obtain the 'Project' resource from the Azure DevOps API related to the Organization/ApiUri
        value provided (where the 'id' of the 'Project' is equal to 'YourProjectId').
#>
function Get-AzDevOpsApiResourceUri
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter()]
        [ValidateScript( { Test-AzDevOpsApiVersion -ApiVersion $_ -IsValid })]
        [System.String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsApiResourceId -ResourceId $_ -IsValid })]
        [System.String]
        $ResourceId
    )

    [string]$apiResourceUri = $ApiUri




    # TODO: Need something to pluralise and lowercase this resource for the URI
    $resourceNamePluralUriString = $ResourceName.ToLower() + "s"

    # TODO: Need to get this from input parameter?
    $apiVersionUriParameter = "api-version=$ApiVersion"

    # TODO: Need to generate this from a function
    $apiResourceUri = $ApiUri + "/$resourceNamePluralUriString"
    if (![System.String]::IsNullOrWhiteSpace($ResourceId))
    {
        $apiResourceUri = $apiResourceUri + "/$ResourceId"
    }
    $apiResourceUri = $apiResourceUri + '?' + $apiVersionUriParameter



    return $apiResourceUri
}
