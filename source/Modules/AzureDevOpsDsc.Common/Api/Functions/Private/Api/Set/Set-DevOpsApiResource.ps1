<#
    .SYNOPSIS
        Attempts to update a resource within Azure DevOps.

        The type of resource type updated is provided in the 'ResourceName' parameter and it is
        assumed that the 'Resource' parameter value passed in meets the specification of the resource.

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
        The name of the resource being updated within Azure DevOps (e.g. 'Project')

    .PARAMETER Resource
        The resource being updated (typically provided by another function (e.g. 'Set-AzDevOpsApiProject')).

    .EXAMPLE
        Set-DevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -Resource $YourResource -Wait

        Updates the 'Project' resource in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, the '-Wait' switch is provided so the function will wait for the corresponding API 'Operation'
        to complete before the function completes. No return value is provided by this function and if the creation of the
        resource has failed, an exception will be thrown.

    .EXAMPLE
        Set-DevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -Resource $YourResource

        Updates the 'Project' resource in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, no '-Wait' switch is provided so the request is made to the API but the operation may
        not complete before the function completes (and may not complete successfully at all).
#>
function Set-DevOpsApiResource
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
        [ValidateScript({ Test-AzDevOpsApiResourceId -ResourceId $_ -IsValid })]
        [System.String]
        $ResourceId,

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
            ResourceId = $ResourceId
        }

        [string]$apiResourceUri = Get-AzDevOpsApiResourceUri @apiResourceUriParameters
        [Hashtable]$apiHttpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat
        [string]$apiHttpRequestBody = $Resource | ConvertTo-Json -Depth 10 -Compress

        [System.Object]$apiOperation = $null
        [System.Object]$apiOperation = Invoke-AzDevOpsApiRestMethod -Uri $apiResourceUri -Method 'Patch' `
                                                         -Headers $apiHttpRequestHeader -Body $apiHttpRequestBody `
                                                         -ContentType 'application/json'

        if ($Wait)
        {
            # Waits for operation to complete successfully. Throws exception if operation is not successful and/or timeout is reached.
            Wait-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat `
                                   -OperationId $apiOperation.id `
                                   -IsSuccessful

            # Adds an additional, post-operation delay/buffer to mitigate subsequent calls trying to obtain new/updated items too quickly from the API
            Start-Sleep -Milliseconds $(Get-AzDevOpsApiWaitIntervalMs)
        }
    }
}
