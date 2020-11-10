<#
    .SYNOPSIS
        Tests for the presence of an Azure DevOps API Resource.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER ApiVersion
        The version of the Azure DevOps API to use in the call/execution to/against the API.

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/Resources
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent Resources being performed.

    .PARAMETER ResourceName
        The name of the resource being updated within Azure DevOps (e.g. 'Project')

    .PARAMETER ResourceId
        The 'id' of the Azure DevOps API Resource. This is typically obtained from a response
        provided by the API when a request is made to it.

    .EXAMPLE
        Test-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' `
                                 -ResourceName 'YourResourceName' -ResourceId 'YourResourceId'

        Tests that the Azure DevOps 'Resource' (identified by the 'ResourceId' for the resource of type
        provided by the 'ResourceName' field) exists. Returns $true if it exists and returns $false
        if it does not.
#>
function Test-AzDevOpsApiResource
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
        [ValidateScript({ Test-AzDevOpsResourceId -ResourceId $_ -IsValid })]
        [Alias('Id')]
        [System.String]
        $ResourceId
    )

    [object[]]$apiResource = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat `
                                                     -ResourceName $ResourceName `
                                                     -ResourceId $ResourceId

    return ($apiResource.Count -gt 0)
}
