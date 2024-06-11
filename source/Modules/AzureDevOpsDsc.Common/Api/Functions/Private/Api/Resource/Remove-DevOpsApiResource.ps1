<#
    .SYNOPSIS
        Attempts to remove a resource within Azure DevOps.

        The type of resource type removed is provided in the 'ResourceName' parameter and it is
        assumed that the 'ResourceId' parameter value passed in is present (in order to be deleted).

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER ApiVersion
        The version of the Azure DevOps API to use. Defaults to value suppored by the module.

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ResourceName
        The name of the resource being deleted within Azure DevOps (e.g. 'Project')

    .PARAMETER ResourceId
        The 'ResourceId' of the resource being created (typically provided by another function (e.g. 'Remove-AzDevOpsApiProject')).

    .PARAMETER Wait
        Using this switch ensures that the execution will run synchronously and wait for the resource to be removed before
        continuing. By not using this switch, execution will run asynchronously.

    .PARAMETER Force
        Using this switch will override any confirmations prior to the deletion/removal of the resource.

    .EXAMPLE
        Remove-DevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId $YourResourceId -Wait

        Removes/Deletes the 'Project' resource in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, the '-Wait' switch is provided so the function will wait for the corresponding API 'Operation'
        to complete before the function completes. No return value is provided by this function and if the creation of the
        resource has failed, an exception will be thrown.

    .EXAMPLE
        New-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId $YourResourceId

        Remmoves/Deletes the 'Project' resource in Azure DevOps within to the Organization relating to the to the 'ApiUri'
        provided.

        NOTE: In this example, no '-Wait' switch is provided so the request is made to the API but the operation may
        not complete before the function completes (and may not complete successfully at all).
#>
function Remove-DevOpsApiResource
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
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.Object]
        [ValidateScript({ Test-AzDevOpsApiResourceId -ResourceId $_ -IsValid })]
        $ResourceId,

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

        [System.Object]$apiOperation = $null
        [System.Object]$apiOperation = Invoke-AzDevOpsApiRestMethod -Uri $apiResourceUri -Method 'Delete' `
                                                         -Headers $apiHttpRequestHeader

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
