<#
    .SYNOPSIS
        Returns a full URI for the API object given the parameter values provided.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER ApiVersion
        The version of the Azure DevOps API to use in the call/execution to/against the API.

    .PARAMETER ObjectName
        The name of the object being obtained from the Azure DevOps API (e.g. 'Project' or 'Operation')

    .PARAMETER ObjectId
        The 'id' of the object type being obtained. For example, if the 'ObjectName' parameter value
        was 'Project', the 'ObjectId' value would be assumed to be the 'id' of a 'Project'.

    .EXAMPLE
        Get-AzDevOpsApiObjectUri -ApiUri 'YourApiUriHere' -ObjectName 'Project'

        Returns a URI to obtain all 'Project' objects from the Azure DevOps API related to the Organization/ApiUri
        value provided.

    .EXAMPLE
        Get-AzDevOpsApiObjectUri -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ObjectName 'Project' -ObjectId 'YourProjectId'

        Returns a URI to obtain the 'Project' object from the Azure DevOps API related to the Organization/ApiUri
        value provided (where the 'id' of the 'Project' is equal to 'YourProjectId').
#>
function Get-AzDevOpsApiObjectUri
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
        [ValidateScript({ Test-AzDevOpsApiObjectName -ObjectName $_ -IsValid })]
        [System.String]
        $ObjectName,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsApiObjectId -ObjectId $_ -IsValid })]
        [System.String]
        $ObjectId
    )

    [string]$apiObjectUri = $ApiUri

    return $apiObjectUri
}
