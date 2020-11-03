<#
    .SYNOPSIS
        Tests the status of an Azure DevOps API operation.

        NOTE: Use of one of the '-IsSuccessful' or '-IsComplete' switch is required.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER OperationId
        The 'id' of the Azure DevOps API operation. This is typically obtained from a response
        provided by the API when a request is made to it.

    .PARAMETER IsComplete
        Use of this switch will ensure the function tests for the Azure DevOps API operation
        to be completed (Note: The operation could complete with error or/and without success).

        Failure to use this switch or the '-IsSuccessful' one as an alternative will throw an
        exception.

    .PARAMETER IsSuccessful
        Use of this switch will ensure the function tests for the Azure DevOps API operation
        to be successfully completed (Note: The operation must have completed with success).

        Failure to use this switch or the '-IsComplete' one as an alternative will throw an
        exception.

    .EXAMPLE
        Test-AzDevOpsOperation -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -OperationId 'YourOperationId' `
                               -IsComplete

        Tests that the Azure DevOps 'Operation' (identified by the 'OperationId') has completed (although the
        operation may not have completed successfully). Returns $true if it has completed and returns $false
        if it has not.

    .EXAMPLE
        Test-AzDevOpsOperation -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -OperationId 'YourOperationId' `
                               -IsSuccessful

        Tests that the Azure DevOps 'Operation' (identified by the 'OperationId') has completed successfully.
        Returns $true if it has completely successfully and returns $false if it has not.
#>
function Test-AzDevOpsOperation
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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
        [ValidateScript({ Test-AzDevOpsOperationId -OperationId $_ -IsValid })]
        [Alias('Id')]
        [System.String]
        $OperationId,

        [Parameter(Mandatory = $true, ParameterSetName = 'IsComplete')]
        [System.Management.Automation.SwitchParameter]
        $IsComplete,

        [Parameter(Mandatory = $true, ParameterSetName = 'IsSuccessful')]
        [System.Management.Automation.SwitchParameter]
        $IsSuccessful
    )

    if (!$IsComplete -and !$IsSuccessful)
    {
        $errorMessage = $script:localizedData.MandatoryIsCompleteAndIsSuccessfulSwitchesNotUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }
    elseif (!$IsComplete -and !$IsSuccessful) # Failsafe: Unlikely/Impossible to occur while both setup with different 'ParameterSetName' values
    {
        $errorMessage = $script:localizedData.MandatoryIsCompleteAndIsSuccessfulSwitchesBothUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }


    [resource[]]$operation = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat `
                                                 -OperationId $OperationId


    # Reference: https://docs.microsoft.com/en-us/rest/api/azure/devops/operations/operations/get?view=azure-devops-rest-6.0#operationstatus
    if (($IsSuccessful -and $operation.status -eq 'succeeded') -or
        ($IsComplete -and $operation.status -in 'succeeded', 'cancelled', 'failed'))
    {
        return $true
    }

    return $false
}
