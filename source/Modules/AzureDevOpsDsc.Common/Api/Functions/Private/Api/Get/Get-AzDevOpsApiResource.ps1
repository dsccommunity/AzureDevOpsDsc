<#
    .SYNOPSIS
        Returns an array of resources returned from the Azure DevOps API. The type of resource
        returned is generic to make this function reusable across all resources from the API.

        The resource type requested from the API is determined by the 'ResourceName' parameter.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER ApiVersion
        The version of the Azure DevOps API to use in the call/execution to/against the API.

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ResourceName
        The name of the resource being obtained from the Azure DevOps API (e.g. 'Project' or 'Operation')

    .PARAMETER ResourceId
        The 'id' of the resource type being obtained. For example, if the 'ResourceName' parameter value
        was 'Project', the 'ResourceId' value would be assumed to be the 'id' of a 'Project'.

    .EXAMPLE
        Get-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project'

        Returns all 'Project' resources from the Azure DevOps API related to the Organization/ApiUri
        value provided.

    .EXAMPLE
        Get-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId 'YourProjectId'

        Returns the 'Project' resource from the Azure DevOps API related to the Organization/ApiUri
        value provided (where the 'id' of the 'Project' is equal to 'YourProjectId').
#>
function Get-AzDevOpsApiResource
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
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
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsApiResourceId -ResourceId $_ -IsValid })]
        [System.String]
        $ResourceId
    )


    # Prepare 'Get-AzDevOpsApiResourceUri' method parameters
    $apiResourceUriParameters = @{
        ApiUri = $ApiUri
        ApiVersion = $ApiVersion
        ResourceName = $ResourceName
    }

    if (![System.String]::IsNullOrWhiteSpace($ResourceId))
    {
        $apiResourceUriParameters.ResourceId = $ResourceId
    }


    # Prepare 'Invoke-AzDevOpsApiRestMethod' method parameters
    $invokeRestMethodParameters = @{
        Uri = $(Get-AzDevOpsApiResourceUri @apiResourceUriParameters)
        Method = 'Get'
        Headers = $(Get-AzDevOpsApiHttpRequestHeader -Pat $Pat)
    }


    [System.Management.Automation.PSObject]$apiResources = Invoke-AzDevOpsApiRestMethod @invokeRestMethodParameters


    # If not a single, resource request, set from the resource(s) in the 'value' property within the response
    if ($null -ne $apiResources.value)
    {
        [System.Management.Automation.PSObject[]]$apiResources = $apiResources.value
    }


    return $apiResources
}
