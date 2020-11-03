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


    # Obtain URI-specific names relating to $ResourceName
    [string]$apiUriResourceAreaName = Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName
    [string]$apiUriResourceName = Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName


    # Append the URI-specific, 'AreaName' of the 'Resource' onto the URI (only if not in the 'core' area)
    if ($apiResourceAreaName -ne 'core')
    {
        $apiResourceUri = $apiResourceUri + "$apiUriResourceAreaName/"
    }


    # Append the URI-specific, 'ResourceName' of the 'Resource' onto the URI
    $apiResourceUri = $apiResourceUri + "$apiUriResourceName/"


    # Append the identifier of the resource, if provided
    if (![System.String]::IsNullOrWhiteSpace($ResourceId))
    {
        $apiResourceUri = $apiResourceUri + "$ResourceId/"
    }


    # Append any parameters to the URI
    $apiResourceUriParameters = @{
        "api-version" = $ApiVersion  # Taken from input parameter
    }

    $apiResourceUri = $apiResourceUri + '?'
    $apiResourceUriParameters.Keys | ForEach-Object {

        $apiResourceUri = $apiResourceUri + '&' + $_ + '=' + $apiResourceUriParameters[$_]
    }
    $apiResourceUri = $apiResourceUri.Replace('/?&','?') # Tidy up the end of base URI where initial parameter begins


    return $apiResourceUri
}
