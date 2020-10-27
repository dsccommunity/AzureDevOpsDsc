<#
    .SYNOPSIS
        Returns an array of objects returned from the Azure DevOps API. The type of object
        returned is generic to make this function reusable across all objects from the API.

        The object type requested from the API is determined by the 'ObjectName' parameter.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ObjectName
        The name of the object being obtained from the Azure DevOps API (e.g. 'Project' or 'Operation')

    .PARAMETER ObjectId
        The 'id' of the object type being obtained. For example, if the 'ObjectName' parameter value
        was 'Project', the 'ObjectId' value would be assumed to be the 'id' of a 'Project'.

    .EXAMPLE
        Get-AzDevOpsApiObject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ObjectName 'Project'

        Returns all 'Project' objects from the Azure DevOps API related to the Organization/ApiUri
        value provided.

    .EXAMPLE
        Get-AzDevOpsApiObject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ObjectName 'Project' -ObjectId 'YourProjectId'

        Returns the 'Project' object from the Azure DevOps API related to the Organization/ApiUri
        value provided (where the 'id' of the 'Project' is equal to 'YourProjectId').
#>
function Get-AzDevOpsApiObject
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Operation','Project')]
        [System.String]
        $ObjectName,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsObjectId -ObjectId $_ -IsValid })]
        [System.String]
        $ObjectId
    )

    # Remove any $ObjectId if using a wildcard character
    # TODO: Might want to make this more generic (i.e. if !(Test-AzDevOpsObjectId $ObjectId -IsValid') then set to $null)
    if ($ObjectId -contains '*')
    {
        $ObjectId = $null
    }

    # TODO: Need something to pluralise and lowercase this object for the URI
    $objectNamePluralUriString = $ObjectName.ToLower() + "s"

    # TODO: Need to get this from input parameter?
    $apiVersionUriParameter = 'api-version=5.1'

    # TODO: Need to generate this from a function
    $apiObjectUri = $ApiUri + "/$objectNamePluralUriString"
    if (![System.String]::IsNullOrWhiteSpace($ObjectId))
    {
        $apiObjectUri = $apiObjectUri + "/$ObjectId"
    }
    $apiObjectUri = $apiObjectUri + '?' + $apiVersionUriParameter



    [Hashtable]$apiHttpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

    # TODO: Need to tidy up?
    [System.Object[]]$apiObjects = @()
    $apiObjects += Invoke-RestMethod -Uri $apiObjectUri -Method 'Get' -Headers $apiHttpRequestHeader

    # If not a single, object request, set from the object(s) in the 'value' property within the response
    if ([System.String]::IsNullOrWhiteSpace($ObjectId))
    {
        [System.Object[]]$apiObjects = $apiObjects.value
    }

    return $apiObjects
}
