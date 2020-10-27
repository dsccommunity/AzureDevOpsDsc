<#
    .SYNOPSIS
        Attempts to create an object within Azure DevOps.

        The type of object type created is provided in the 'ObjectName' parameter and it is
        assumed that the 'Object' parameter value passed in meets the specification of the object.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ObjectName
        The name of the object being created within Azure DevOps (e.g. 'Project')

    .PARAMETER Object
        The object being created (typically provided by another function (e.g. 'New-AzDevOpsApiProject')).

    .EXAMPLE
        New-AzDevOpsApiObject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ObjectName 'Project' -Object $YourObject -Wait

        Creates the 'Project' object in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, the '-Wait' switch is provided so the function will wait for the corresponding API 'Operation'
        to complete before the function completes. If the creation of the object has been successful, it will be return by the
        function. If the creation of the object has failed, an exception will be thrown.

    .EXAMPLE
        New-AzDevOpsApiObject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ObjectName 'Project' -Object $YourObject

        Creates the 'Project' object in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, no '-Wait' switch is provided so the request is made to the API but the operation may
        not complete before the function completes (and may not complete successfully at all).
#>
function New-AzDevOpsApiObject
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Operation','Project')]
        [System.String]
        $ObjectName,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Object,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Wait,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    $objectId = $Object.id # TODO: Might have to remove the assumption that this works (see below also). Input object's 'id' value looks to be ignored when creating object.

    # TODO: Need something to pluralise and lowercase this object for the URI
    $objectNamePluralUriString = $ObjectName.ToLower() + "s"

    # TODO: Need something to convert to JSON
    $objectJson = $Object | ConvertTo-Json -Depth 10 -Compress

    # TODO: Need to get this from input parameter?
    $apiVersionUriParameter = 'api-version=5.1'

    # TODO: Need to generate this from a function
    $apiObjectUri = $ApiUri + "/$objectNamePluralUriString" + '?' + $apiVersionUriParameter



    if ($Force -or $PSCmdlet.ShouldProcess($apiObjectUri, $ObjectName))
    {
        [System.Object]$apiOperation = $null
        [Hashtable]$apiHttpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

        [System.Object]$apiOperation = Invoke-RestMethod -Uri $apiObjectUri -Method 'Post' -Headers $apiHttpRequestHeader -Body $objectJson -ContentType 'application/json'

        if ($Wait)
        {
            # Waits for operation to complete successfully. Throws exception if operation is not successful and/or timeout is reached.
            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat `
                                   -OperationId $apiOperation.id `
                                   -IsSuccessful

            # Obtains and returns the new object
            New-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat `
                                  -ObjectName $ObjectName `
                                  -ObjectId $objectId # TODO: Might have to remove the assumption that this works (see above also). Input object's 'id' value looks to be ignored when creating object.
        }
    }
}
