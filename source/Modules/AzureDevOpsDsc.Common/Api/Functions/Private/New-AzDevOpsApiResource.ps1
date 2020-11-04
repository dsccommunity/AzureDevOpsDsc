<#
    .SYNOPSIS
        Attempts to create an resource within Azure DevOps.

        The type of resource type created is provided in the 'ResourceName' parameter and it is
        assumed that the 'Resource' parameter value passed in meets the specification of the resource.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ResourceName
        The name of the resource being created within Azure DevOps (e.g. 'Project')

    .PARAMETER Resource
        The resource being created (typically provided by another function (e.g. 'New-AzDevOpsApiProject')).

    .EXAMPLE
        New-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -Resource $YourResource -Wait

        Creates the 'Project' resource in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, the '-Wait' switch is provided so the function will wait for the corresponding API 'Operation'
        to complete before the function completes. No return value is provided by this function and if the creation of the
        resource has failed, an exception will be thrown.

    .EXAMPLE
        New-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -Resource $YourResource

        Creates the 'Project' resource in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, no '-Wait' switch is provided so the request is made to the API but the operation may
        not complete before the function completes (and may not complete successfully at all).
#>
function New-AzDevOpsApiResource
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

        [Parameter()]
        [ValidateScript( { Test-AzDevOpsApiVersion -ApiVersion $_ -IsValid })]
        [System.String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Resource,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Wait,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess($apiResourceUri, $ResourceName))
    {
        $apiResourceUriParameters = @{
            ApiUri = $ApiUri
            ApiVersion = $ApiVersion
            ResourceName = $ResourceName
        }

        [string]$apiResourceUri = Get-AzDevOpsApiResourceUri @apiResourceUriParameters
        [Hashtable]$apiHttpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat
        [string]$apiHttpRequestBody = $Resource | ConvertTo-Json -Depth 10 -Compress

        [System.Object]$apiOperation = $null
        [System.Object]$apiOperation = Invoke-RestMethod -Uri $apiResourceUri -Method 'Post' `
                                                         -Headers $apiHttpRequestHeader -Body $apiHttpRequestBody `
                                                         -ContentType 'application/json'

        if ($Wait)
        {
            # Waits for operation to complete successfully. Throws exception if operation is not successful and/or timeout is reached.
            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat `
                                   -OperationId $apiOperation.id `
                                   -IsSuccessful
        }
    }
}
