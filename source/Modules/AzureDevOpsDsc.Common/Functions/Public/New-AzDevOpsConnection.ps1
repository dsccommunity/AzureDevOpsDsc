<#
    .SYNOPSIS
        Creates a 'Connection' (assocated with the Organization/ApiUrl) to be used with other functions/cmdlets in this PSModule.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER Credential
        The 'Credential' to be used by any subsequent requests against the Azure DevOps API.
        This credential must have the relevant permissions assigned for the subsequent operations
        being performed.

    .EXAMPLE
        New-AzDevOpsConnection -ApiUri 'YourApiUriHere' -Pat 'YourPatHere'

        Creates a 'Connection' (assocated with the Organization/ApiUrl and using a provided 'Personal Access Token' (PAT)) to be used with other functions/cmdlets in this PSModule.

    .EXAMPLE
        New-AzDevOpsConnection -ApiUri 'YourApiUriHere' -Credential $YourCredentialHere

        Creates a 'Connection' (assocated with the Organization/ApiUrl and using a provided 'PSCredential' object) to be used with other functions/cmdlets in this PSModule.
#>
function New-AzDevOpsConnection
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter(Mandatory = $true, ParameterSetName = 'Pat')]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true, ParameterSetName = 'Credential')]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    [System.Object]$connection = $null

    # TODO!

    return $connection
}
