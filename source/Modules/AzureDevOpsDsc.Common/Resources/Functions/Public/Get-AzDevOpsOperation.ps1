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

        Returns the 'Operation' resource from Azure DevOps related to the 'OperationId' value provided.
#>
function Get-AzDevOpsOperation
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
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

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsOperationId -OperationId $_ -IsValid })]
        [Alias('ResourceId','Id')]
        [System.String]
        $OperationId
    )

    # Prepare parameters for 'Get-AzDevOpsApiResource' invocation
    $azDevOpsApiResourceParameters = @{
        ApiUri = $ApiUri;
        Pat = $Pat;
        ResourceName = 'Operation'
    }

    if (-not[System.String]::IsNullOrWhiteSpace($OperationId))
    {
        $azDevOpsApiResourceParameters.ResourceId = $OperationId
    }

    # Obtain "Operation" resources
    [System.Management.Automation.PSObject[]]$apiResources = Get-AzDevOpsApiResource @azDevOpsApiResourceParameters

    # Filter "Operation" resources
    if (-not[System.String]::IsNullOrWhiteSpace($OperationId))
    {
        $apiResources = $apiResources | Where-Object { $_.id -eq $OperationId }
    }

    return [System.Management.Automation.PSObject[]]$apiResources

}
