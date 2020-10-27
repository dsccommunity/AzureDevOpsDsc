<#
    .SYNOPSIS
        Returns an Azure DevOps 'Operation' as identified by the 'OperationId' provided.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER OperationId
        The 'id' of the 'Operation' being obtained/requested.

    .EXAMPLE
        Get-AzDevOpsOperation -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -OperationId 'YourOperationIdHere'

        Returns the 'Operation' object from Azure DevOps related to the 'OperationId' value provided.
#>
function Get-AzDevOpsOperation
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
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
        [Alias('Id')]
        [System.String]
        $OperationId
    )

    [System.Object[]]$apiObjects = Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat `
                                                         -ObjectName 'Operation' `
                                                         -ObjectId $OperationId

    return $apiObjects |
        Where-Object id -ilike $OperationId
}
