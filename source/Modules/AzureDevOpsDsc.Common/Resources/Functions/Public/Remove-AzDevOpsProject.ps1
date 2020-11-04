<#
    .SYNOPSIS
        Removes/deletes a Azure DevOps 'Project' with the provided 'ProjectId'.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ProjectId
        The 'id' of the 'Project' being deleted.

    .PARAMETER Force
        When this switch is used, any confirmation will be overidden/ignored.

    .EXAMPLE
        New-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' `
                            -ProjectName 'YourProjectNameHere' `
                            -ProjectDescription 'YourProjectDescriptionHere' -SourceControlType 'Git'

        Creates a 'Project' (assocated with the Organization/ApiUrl) in Azure DevOps using project-related, parameter values provided.
#>
function Remove-AzDevOpsProject
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
        [ValidateScript({ Test-AzDevOpsProjectId -ProjectId $_ -IsValid })]
        [Alias('Id')]
        [System.String]
        $ProjectId,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess($ApiUri, $ResourceName))
    {
        Remove-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat `
                                   -ResourceName 'Project' `
                                   -ResourceId $ProjectId `
                                   -Force:$Force -Wait | Out-Null

    }
}
